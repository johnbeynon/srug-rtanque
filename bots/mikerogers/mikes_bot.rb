class MikesBot < RTanque::Bot::Brain
  NAME = 'Mikes Bot'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 5.0

  def tick!
    ## main logic goes here

    def tick!
      @desired_heading ||= nil
      @desired_turret_heading ||= (RTanque::Heading::ONE_DEGREE * 90)
      @health ||= 100

      self.wall_search
      self.turret_spin
      self.health_check

      command.speed = 3
      command.fire_power = 5
      command.fire(0)
    end

    def wall_search
      if sensors.position.on_wall? then
        @desired_heading = sensors.heading + (RTanque::Heading::ONE_DEGREE * 100)
      end

      if @desired_heading != sensors.heading then 
        command.heading = @desired_heading
      end
    end

    def turret_spin
      # If we're touching a wall, make sure were firing towards the middle.
      if sensors.position.on_bottom_wall?
        @desired_turret_heading = (RTanque::Heading::ONE_DEGREE * 0)
      elsif sensors.position.on_right_wall?
        @desired_turret_heading = (RTanque::Heading::ONE_DEGREE * 270)
      elsif sensors.position.on_top_wall?
        @desired_turret_heading = (RTanque::Heading::ONE_DEGREE * 180)
      elsif sensors.position.on_left_wall?
        @desired_turret_heading = (RTanque::Heading::ONE_DEGREE * 90)
      end

      if @desired_turret_heading == sensors.turret_heading
        @desired_turret_heading = sensors.heading + (RTanque::Heading.rand)
      end
      command.turret_heading = @desired_turret_heading
    end

    def health_check
      if sensors.health <= 25
        @desired_heading = sensors.heading + (RTanque::Heading::ONE_DEGREE * 100)
      end
    end
  end
end
