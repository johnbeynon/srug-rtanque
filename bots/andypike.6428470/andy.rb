# Andy and Martin from 1minus1

class T1000 < RTanque::Bot::Brain
  NAME = 'T_1000'
  include RTanque::Bot::BrainHelper

  def tick!
    @target ||= nil
    top_speed = MAX_BOT_SPEED / 2
    stop = 0

    scan
    find_target

    command.speed = top_speed
    command.fire(1)

    if @target
      command.turret_heading = @target.heading
      command.heading = @target.heading
      command.radar_heading = @target.heading

      if @target.distance < 250
        command.speed = stop
        #command.fire(MAX_FIRE_POWER)
      else
        command.speed = @target.distance / 100
      end
    end
  end

  def scan
    if @target.nil?
      command.radar_heading = sensors.radar_heading + (RTanque::Heading::ONE_DEGREE * 30)
    end
  end

  def find_target
    @target = sensors.radar.first
  end
end
