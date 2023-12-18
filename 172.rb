def pinspect(*args)
  puts *args.map(&:inspect)
end

class Node

  INF = Float::INFINITY

  VELOCITY_DIRS = %w[n s w e]
  VELOCITY_MAX = 10
  TOTAL_VELOCITIES = VELOCITY_DIRS.length * VELOCITY_MAX



  attr :row
  attr :col
  attr :velocity_dir
  attr :velocity_count
  attr :cost_to_enter
  attr :goal

  attr_accessor :visited
  attr_accessor :distance

  class << self
    def make_stack(row, col, cost_to_enter)
      VELOCITY_DIRS.flat_map do | d |
        (1..10).map { |x| Node.new(row, col, cost_to_enter, d, x) }
      end
    end

    def stack_position(direction, count)
      VELOCITY_DIRS.index(direction) * VELOCITY_MAX + (count - 1)
    end

    def world_at(row, col, velocity)
      if row.between?(0, $max_row - 1) && col.between?(0, $max_col - 1) && velocity.between?(0, TOTAL_VELOCITIES - 1)
        $world[row][col][velocity]
      end
    end

    def shortest_unvisited
      result = nil
      $touched.each do |n|
        if !n.visited && (result.nil? || n.distance < result.distance)
          result = n
        end
      end
      result
    end

  end

  def initialize(row, col, cost_to_enter, velocity_dir, velocity_count)
    @distance = INF
    @visited = false

    @row = row
    @col = col
    @cost_to_enter = cost_to_enter
    @velocity_dir = velocity_dir
    @velocity_count = velocity_count
    @goal = row == $max_row - 1 && col == $max_col - 1 && velocity_count >=4
  end

  def neighbours
    [north_neighbour, south_neighbour, west_neighbour, east_neighbour].compact
  end

  def unvisited_neighbours
    neighbours.filter { |n| !n.visited }
  end

  def north_neighbour
    neighbour('n', 's', -1, 0)
  end

  def south_neighbour
    neighbour('s', 'n', 1, 0)
  end

  def west_neighbour
    neighbour('w', 'e', 0, -1)
  end

  def east_neighbour
    neighbour('e', 'w', 0, 1)
  end

  def neighbour(letter, backwards, dr, dc)

    return nil if velocity_dir == backwards # no going backwards
    return nil if velocity_dir != letter && velocity_count < 4 # can't go less than 4
    return nil if velocity_dir == letter && velocity_count == VELOCITY_MAX # can't go more than 10

    if velocity_dir != letter
      nvelocity = Node.stack_position(letter, 1)
    else
      nvelocity = Node.stack_position(letter, velocity_count + 1)
    end

    nrow = row + dr
    ncol = col + dc

    Node.world_at(nrow, ncol, nvelocity)
  end

end

def print_world
  puts "\e[H\e[2J"
  $world.each do |r|
    r.each do |c|
      print("#{c.filter(&:visited).length.to_s(16).rjust(2, ' ')} ")
    end
    puts("")
  end
end



infile = '17.txt'
# infile = '17_sample.txt'
# infile = '17_sample2.txt'

$board = File.readlines(infile, chomp: true).map { | row | row.split('').map(&:to_i) }
$max_row = $board.length
$max_col = $board[0].length

$world = $board.each_with_index.map do |r, ri|
  r.each_with_index.map do |cost, ci|
    Node.make_stack(ri, ci, cost)
  end
end


#create special origin node that has no initial velocity
origin = Node.new(0, 0, $board[0][0], '-', 4)
origin.distance = 0




$touched = Set[]

current = origin
spax = 0
until (current.nil? || current.goal)
  spax += 1
  print_world if spax % 5000 == 0
  # print_world
  # pinspect current
  current.unvisited_neighbours.each do |n|
    # print ("     ")
    # pinspect n
    this_dist = current.distance + n.cost_to_enter
    n.distance = this_dist if this_dist < n.distance
    $touched.add(n)
  end
  current.visited = true
  $touched.delete(current)
  current = Node.shortest_unvisited
end
pinspect current
