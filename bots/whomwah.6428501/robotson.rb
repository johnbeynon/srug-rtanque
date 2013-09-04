class Robotson < RTanque::Bot::Brain
  include RTanque::Bot::BrainHelper

  NAME = 'robotson'
  DIRECTIONS = {
    :n => RTanque::Heading::NORTH,
    :s => RTanque::Heading::SOUTH,
    :e => RTanque::Heading::EAST,
    :w => RTanque::Heading::WEST
  }
  DETECTION_DISTANCE = 10
  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 15.0

  def tick!
    command.speed = RTanque::Bot::MAX_SPEED
    command.heading = sensors.heading + rand(10)

    if DIRECTIONS.values.detect{|d| near_wall?(d) }
      command.speed = Random.rand(RTanque::Bot::MAX_SPEED) * -1
    end

    if (target = nearest_target)
      fire_on(target)
    else
      seek_target
    end
  end

  def near_wall?(wall)
    case wall
    when DIRECTIONS[:n]
      sensors.position.y + DETECTION_DISTANCE >= arena.height
    when DIRECTIONS[:e]
      sensors.position.x + DETECTION_DISTANCE >= arena.width
    when DIRECTIONS[:s]
      sensors.position.y - DETECTION_DISTANCE <= 0
    when DIRECTIONS[:w]
      sensors.position.x - DETECTION_DISTANCE <= 0
    else
      false
    end
  end

  def seek_target
     command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
     command.turret_heading = sensors.radar_heading
   end

  def nearest_target
    reflections = sensors.radar
    reflections = reflections.reject {|r| r.name == NAME }
    reflections.sort_by {|r| r.distance }.first
  end

  def fire_on(reflection)
    command.radar_heading = reflection.heading
    command.turret_heading = reflection.heading

    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(fire_power(reflection))
    end
  end

  def fire_power(baddie)
    if baddie.distance >= 200
      MAX_FIRE_POWER
    elsif baddie.distance < 200 && baddie.distance >= 100
      MIN_FIRE_POWER / 2
    elsif baddie.distance < 100
      MIN_FIRE_POWER
    else
      MIN_FIRE_POWER
    end
  end
end