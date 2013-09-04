class PrinceAlbot < RTanque::Bot::Brain

  # Seek&Destroy: Sample Bot
#
# Enjoys following and target and firing many shots
  NAME = 'Prince Albot I'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::EIGHTH_ANGLE

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
    command.heading = reflection.heading
    command.radar_heading = reflection.heading
    command.turret_heading = reflection.heading
    command.speed = MAX_BOT_SPEED
    command.fire(MIN_FIRE_POWER)
  end

  def seek_lock
    if sensors.position.on_wall?
      @desired_heading = sensors.heading + RTanque::Heading::HALF_ANGLE
    end
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.speed = 1
    if @desired_heading
      command.heading = @desired_heading
      command.turret_heading = @desired_heading
    end
  end

  def get_radar_lock
    @locked_on ||= nil
    lock = if @locked_on
      sensors.radar.find { |reflection| reflection.name == @locked_on } || sensors.radar.first
    else
      sensors.radar.first
    end
    @locked_on = lock.name if lock
    lock
  end
end
