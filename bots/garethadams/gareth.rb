class GBot < RTanque::Bot::Brain
  NAME = 'GBot'
  include RTanque::Bot::BrainHelper

  TickReflection = Struct.new(:reflection, :tick, :position, :direction)

  def known_bots
    @known_bots ||= Hash.new { |hsh, name| hsh[name] = TickReflection.new }
  end

  def distant position, heading, distance
    new_x = position.x + (Math.sin(heading.radians) * distance)
    new_y = position.y + (Math.cos(heading.radians) * distance)

    RTanque::Point.new(new_x, new_y)
  end

  def track bot
    @tracking = bot
  end

  def scan
    command.radar_heading = if @tracking
      if tr = known_bots[@tracking]
        tr.reflection.heading
      else
        sensors.radar_heading + (RTanque::Heading::ONE_DEGREE * 30)
      end
    else
      sensors.radar_heading + (RTanque::Heading::ONE_DEGREE * 30)
    end

    sensors.radar.each do |reflection|
      tr = known_bots[reflection.name]
      previous_position = tr.position if tr.tick && (@ticks - tr.tick < 10)
      tr.tick = @ticks
      tr.reflection = reflection
      tr.position = distant(sensors.position, reflection.heading, reflection.distance)
      if previous_position
        tr.direction = RTanque::Heading.new_between_points previous_position, tr.position
      else
        tr.direction = nil
      end
      puts tr.inspect
    end
  end

  def tick!
    @ticks ||= 0
    @ticks += 1

    scan

    target = known_bots.sort_by { |name, tr| -tr.reflection.distance }.first

    victim, tr = target

    if target
      command.heading = RTanque::Heading.new_between_points(sensors.position, tr.position)
      ticks_missing = @ticks - tr.tick
      command.speed = 3 - (ticks_missing / 60)

      if tr.direction
        prediction = distant tr.position, tr.direction, 30
        command.turret_heading = RTanque::Heading.new_between_points(sensors.position, prediction)
      else
        command.turret_heading = tr.reflection.heading
      end

      track(ticks_missing < 30 ? victim : nil)
    else
      track nil
      command.turret_heading = sensors.turret_heading + (RTanque::Heading::ONE_DEGREE * 30)
    end
    command.fire (1..5).to_a.sample

  end
end
