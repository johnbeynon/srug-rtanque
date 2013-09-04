class Benbot < RTanque::Bot::Brain
  include RTanque::Bot::BrainHelper
  NAME = "benbot"
  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 5.0
  THRESHOLD = 60

  def tick!
    check_hit
    if (target = closest_target)
      fire(target)
    else
      seek
    end
    command.speed = get_speed
    new_heading = get_new_heading
    if new_heading
      @target = new_heading
    end
    command.heading = @target
  end

  def fire(reflection)
    command.radar_heading = command.turret_heading = reflection.heading
    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(reflection.distance > 150 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end

  def get_speed
    if hit?
      RTanque::Bot::MAX_SPEED
    else
      [4,5].sample
    end
  end

  def get_new_heading
    if hit?
      sensors.heading + [RTanque::Heading::HALF_ANGLE,RTanque::Heading::EIGHTH_ANGLE].sample
    elsif near?(:t)
      RTanque::Heading::SE
    elsif near?(:r)
      RTanque::Heading::SW
    elsif near?(:b)
      RTanque::Heading::NW
    elsif near?(:l)
      RTanque::Heading::NE
    end
  end

  def seek
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.turret_heading = sensors.radar_heading
  end

  def closest_target
    sensors.radar.min { |a,b| a.distance <=> b.distance }
  end

  def near?(wall)
    case wall
    when :t
      sensors.position.y + THRESHOLD >= self.arena.height
    when :r
      sensors.position.x + THRESHOLD >= self.arena.width
    when :b
      sensors.position.y - THRESHOLD <= 0
    when :l
      sensors.position.x - THRESHOLD <= 0
    else
      false
    end
  end

  def check_hit
    @hit = (@last_health && @last_health != sensors.health)
    @last_health = sensors.health
  end

  def hit?
    @hit
  end
end
