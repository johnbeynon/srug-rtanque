class Nyx < RTanque::Bot::Brain
  NAME = 'nyx'
  include RTanque::Bot::BrainHelper

  attr_accessor :target, :previous_target, :projected_target_heading

  def tick!
    seek_radar

    if target = nearest_target

      puts "target: " + target.heading.inspect
      puts "previous: " + previous_target.heading.inspect if self.previous_target
      if previous_target
        diff = target.heading.to_degrees - previous_target.heading.to_degrees
        new_heading = target.heading.to_degrees + diff
        puts "projected r: " + previous_target.inspect
        self.projected_target_heading = RTanque::Heading.new_from_degrees new_heading
      end

      self.command.radar_heading = target.heading
      self.command.heading = projected_target_heading
      self.command.speed = MAX_BOT_SPEED

      self.command.turret_heading = projected_target_heading || target.heading
      self.command.fire MAX_FIRE_POWER  #(target.distance > 200 ? MAX_FIRE_POWER : MIN_FIRE_POWER)

      # store previous
      self.previous_target = target
    else
      self.command.speed = 3
      self.command.heading = (self.command.heading || 0) / 2
    end

  end

  def nearest_target
    #puts self.sensors.radar.map {|r| r.class }
    self.sensors.radar.each do |reflection|
      return reflection
    end
    #self.sensors.radar.min { |a,b| a.distance <=> b.distance }
    return nil
  end

  def seek_radar
    self.command.radar_heading = self.sensors.radar_heading + MAX_RADAR_ROTATION
  end

  #def get_radar_lock
    #@locked_on ||= nil
    #lock = if @locked_on
      #sensors.radar.find { |reflection| reflection.name == @locked_on } || sensors.radar.first
    #else
      #sensors.radar.first
    #end
    #@locked_on = lock.name if lock
    #lock
  #end
end
