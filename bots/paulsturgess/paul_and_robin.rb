class PaulAndRobin < RTanque::Bot::Brain
  NAME = 'paul_and_robin'
  include RTanque::Bot::BrainHelper

  def tick!
    command.speed = 1.5
    new_heading = if sensors.position.on_wall?
      sensors.heading + RTanque::Heading::HALF_ANGLE
    else
      RTanque::Heading.rand
    end
    command.heading = new_heading
    if bots_in_vision.any?
      command.turret_heading = nearest_bot.heading
      command.fire(1)
    else
      seek_heading = sensors.turret_heading + RTanque::Heading.new_from_degrees(10)
      command.turret_heading = seek_heading
      command.radar_heading = seek_heading
    end
  end

  def nearest_bot
    bots_in_vision.first
  end

  def bots_in_vision
    sensors.radar.sort_by(&:distance)
  end

end