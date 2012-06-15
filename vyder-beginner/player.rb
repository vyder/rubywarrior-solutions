require 'constants'

class Player
    
  def level_init(warrior)
    @warrior = warrior
    @health = warrior.health
    @backingUp = false
    
    @togo = [:forward, :backward]

    @has_init_level = true
  end
  
  def play_turn(warrior)
    @has_init_level |= false
    
    level_init(warrior) if !@has_init_level
    
    # go forward blindly if you ever happen to run out of places to go
    @togo << :forward if @togo.empty?
    
    @heading = @togo.first # direction currently heading in
    @nextSpace = warrior.feel(@togo.first)
    @horizon = warrior.look(@heading) # look where we are going

    if enemy_somewhere_in_front? and !shot_at?
      warrior.shoot!
    elsif warrior.feel.wall? # if you're facing a wall
      warrior.pivot!
      @togo = @togo.map {|dir| OPPOSITE_DIRECTIONS[dir] }
    elsif @nextSpace.wall?
      @togo.shift # remove this direction from list
    elsif !shot_at? and safe? and low_health?
      warrior.rest!
    elsif @nextSpace.captive?
      warrior.rescue!(@heading)
    elsif @nextSpace.enemy?
      warrior.attack!(@heading)
    else
      # backup out of range
      if shot_at? and warrior.health < MAX_HEALTH*0.6 and !@backingUp
        @togo.unshift(OPPOSITE_DIRECTIONS[@heading])
        @backingUp = true
      elsif @backingUp and @nextSpace.wall? and warrior.health >= MAX_HEALTH*0.6
        puts "Done backing up"
        @togo.shift
        @backingUp = false
      end
      
      nearest_enemy = get_nearest_enemy
      
      # So at this point, if you are being shot at, you have to decide best form of attack
      if shot_at? and !nearest_enemy.nil?
        
        if nearest_enemy[:type] == "Archer"
          if nearest_enemy[:distance] > 0
            warrior.walk! nearest_enemy[:direction]
          else
            warrior.attack! nearest_enemy[:direction]
          end
          return
        elsif nearest_enemy[:type] == "Wizard"
          warrior.shoot! nearest_enemy[:direction]
        elsif ["Sludge", "Thick Sludge"].include?(nearest_enemy[:type])
          if nearest_enemy[:distance] > 0
            warrior.walk! nearest_enemy[:direction]
          else
            warrior.attack! nearest_enemy[:direction]
          end
          return
        end
      end
      
      warrior.walk!(@heading)
    end
    @health = warrior.health
  end
  
  def get_nearest_enemy 
    enemy = {
      :direction => nil,
      :type => nil,
      :distance => nil
    }
    @forwardEnemies = @warrior.look(:forward)
    @backwardEnemies = @warrior.look(:backward)
    
    for i in 0...3 do
      if @forwardEnemies[i].enemy?
        enemy[:direction] = :forward
        enemy[:type] = @forwardEnemies[i].to_s
        enemy[:distance] = i
        return enemy
      elsif @backwardEnemies[i].enemy?
        enemy[:direction] = :backward
        enemy[:type] = @backwardEnemies[i].to_s
        enemy[:distance] = i
        return enemy
      end
    end
    
    return nil
  end
  
  def low_health?
    @warrior.health < 3*MAX_HEALTH/4
  end
  
  def shot_at?
    @warrior.health < @health
  end
  
  def safe?
    @nextSpace.empty? or @nextSpace.wall?
  end
  
  def enemy_somewhere_in_front?
    @horizon.each do |space, index|
      return false if space.captive? # There is a captive in the way, don't shoot
      return true if space.enemy? and index != 0
    end
    false
  end
  
  # def turnaround!
  #   # @warrior.pivot!
  #   # reverse @togo
  #   @togo = @togo.map {|dir| OPPOSITE_DIRECTIONS[dir] }
  # end
  
  # if warrior.listen.empty?
  def head_for_the_stairs
    toStairs = @warrior.direction_of_stairs
    @warrior.walk! toStairs
  end
end
