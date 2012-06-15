class Player
  MAX_HEALTH = 20
  OPPOSITE_DIRECTIONS = {
    :forward => :backward,
    :backward => :forward,
    :left => :right,
    :right => :left
  }
  
  def level_init(warrior)
    @initLevel = true
    @dirs = [:forward, :backward, :left, :right]
    @warrior = warrior
    @unbound_enemies = 3
    @backup = nil
  end
  
  def full_health?
    ! (@warrior.health < MAX_HEALTH)
  end
  
  
  def play_turn(warrior)
    @initLevel |= false # init to false only if nil

    level_init(warrior) if !@initLevel # Set class variables
    
    puts warrior.listen[0].class

    if warrior.listen.empty?
      head_for_the_stairs
    elsif !@backup.nil?
      if !full_health?
        warrior.rest!
      else
        warrior.walk! @backup
        @backup = nil
      end
        
    elsif warrior.feel(@dirs[0]).captive?
      warrior.rescue!(@dirs[0])
      @unbound_enemies += 1 if warrior.feel(@dirs[0]).enemy?
    elsif warrior.feel(@dirs[0]).enemy?
      if @unbound_enemies >= 2
        warrior.bind!(@dirs[0])
        @dirs.push(@dirs.shift)
        @unbound_enemies -= 1
      else
        warrior.attack!(@dirs[0])
      end
    else # warrior.feel(@dirs[0]).empty?
      if !full_health?
        warrior.walk! @dirs[0]
        @backup = OPPOSITE_DIRECTIONS[@dirs[0]]
      else
        @dirs.shift
      end
    end
  end
  
  def head_for_the_stairs
    toStairs = warrior.direction_of_stairs # dynamic variable
    warrior.walk! toStairs
  end
    
end
