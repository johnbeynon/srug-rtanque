class TomsBot < RTanque::Bot::Brain
  NAME = 'toms_bot'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 1.5

  def tick!
    if we_have_target
      target = we_have_target
      track_target(target)
      command.speed = 5 # takes a value between -5 to 5 
      if sensors.health < 25
        command.heading = target.heading
      else
        command.heading = 0.0
      end
      aim_at_target(target)
      fire_at_target(target)
    else
      self.scan_with_radar
    end
  end

  def we_have_target
    self.nearest_target
  end

  def nearest_target
    self.sensors.radar.min { |a,b| a.distance <=> b.distance }
  end

  def scan_with_radar
    self.command.radar_heading = self.sensors.radar_heading + MAX_RADAR_ROTATION
  end

  def track_target(target)
    self.command.radar_heading = target.heading
  end

  def aim_at_target(target)
    self.command.turret_heading = target.heading
  end

  def fire_at_target(target)
      if self.pointing_at_target?(target)
        command.fire(0.25)
      end
  end

  def pointing_at_target?(target)
    (target.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
  end
end
