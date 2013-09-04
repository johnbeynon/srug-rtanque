class Homer < RTanque::Bot::Brain
  NAME = 'MyDriveDestroyer'
  include RTanque::Bot::BrainHelper
 
  def tick!
    move
    in_circles
    fire
 
    if someones_close
      shoot_them
    else
      scan_the_radar
    end
  end
 
  def someones_close
    @target = nearest_target
  end
 
  def nearest_target
    target = sensors.radar.min{ |a,b| a.distance <=> b.distance }
  end
 
  def fire
    command.fire(MAX_FIRE_POWER / 5)
  end
 
  def move
    command.speed = MAX_BOT_SPEED * 10
  end
 
  def shoot_them
    command.radar_heading = @target.heading
    command.turret_heading = @target.heading
  end
 
  def scan_the_radar
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
  end
 
  def in_circles
    command.heading = sensors.heading + MAX_BOT_ROTATION
  end
end