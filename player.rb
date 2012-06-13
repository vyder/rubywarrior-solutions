class Player
  def play_turn(warrior)
    direction = warrior.direction_of_stairs
    warrior.feel(direction).enemy? ? warrior.attack!(direction) : warrior.walk!(direction)
  end
end
