class StevesBot < RTanque::Bot::Brain
  NAME = 'steves_bot'
  include RTanque::Bot::BrainHelper

  def tick!
    @ticks_since_radar ||= 100
    @ticks_since_radar += 1
    sensors.radar.each do |scanned_bot|
      @ticks_since_radar = 0
      @last_bot = @bot
      @bot = scanned_bot
    end
    puts [sensors.radar_heading, @last_bot].inspect

    if @bot && @ticks_since_radar < 100
      move(@bot)
      destroy(@bot)
    else
      move(@bot)
      seek
    end
  end

  def move(bot)
    command.speed = 5
  end

  def seek
    command.heading = sensors.heading + Math::PI*0.1
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.turret_heading = Math::PI
    command.fire(2)
  end

  def destroy(bot)
    command.heading = @bot.heading
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.turret_heading = @bot.heading
    command.fire(MAX_FIRE_POWER)
  end
end
