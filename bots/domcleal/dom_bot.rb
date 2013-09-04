# DomBot
#
# Enjoys following and target and firing many shots, marginally better, or
# worse, than seekj & destroy
class DomBot < RTanque::Bot::Brain
  NAME = 'DomBot'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 5.0

  attr_accessor :locked_on
  attr_reader :reflections

  def tick!
    @desired_heading ||= nil

    if (lock = self.get_radar_lock)
      self.destroy_lock(lock)
      @desired_heading = nil
    else
      self.seek_lock
    end
  end

  def destroy_lock(reflection)
    target_heading = anticipate
    command.heading = target_heading
    command.radar_heading = target_heading
    command.turret_heading = target_heading

    command.speed = reflection.distance > 100 ? MAX_BOT_SPEED : MAX_BOT_SPEED / 2.0
    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(reflection.distance > 100 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end

  def seek_lock
    if sensors.position.on_wall?
      @desired_heading = sensors.heading + RTanque::Heading::HALF_ANGLE
    end
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.speed = MAX_BOT_SPEED
    if @desired_heading
      command.heading = @desired_heading
      command.turret_heading = @desired_heading
    end
  end

  def get_radar_lock
    lock = if locked_on
      current_lock = sensors.radar.find { |reflection| reflection.name == locked_on.name }
      sorted_locks = sensors.radar.sort do |a,b|
        reflection_score(a) - reflection_score(b)
      end
      
      if current_lock && sorted_locks.index(current_lock) > (sorted_locks.size / 4)
        # switch targets if the current lock isn't in the top 25%
        puts "TARGET SWITCH: current target is a poor choice"
        current_lock = nil
      end

      current_lock || sorted_locks.first
    else
      sensors.radar.first
    end
    set_lock(lock) if lock
    lock
  end

  # give some kind of score where reduced angle and distance is better
  def reflection_score(reflection)
    heading_pc = (sensors.heading - reflection.heading).abs.to_degrees / 360
    distance_pc = reflection.distance / ((arena.width + arena.height) / 2)
    heading_pc + distance_pc
  end

  def set_lock(reflection)
    unless locked_on && locked_on.name == reflection.name
      # new lock
      (@reflections ||= []).clear
    end
    self.locked_on = reflection
    @reflections << reflection
  end

  # extrapolate the next heading from the last two reflections
  def anticipate
    return @reflections.last.heading unless @reflections.size > 2
    heading = @reflections[-1].heading + 4*(@reflections[-1].heading - @reflections[-2].heading)
    puts "ANTICIPATE: returning #{heading.to_s} instead of #{@reflections[-1].heading.to_s}"
    heading
  end

end
