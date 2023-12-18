def pinspect(*args)
  puts *args.map(&:inspect)
end

class Node

  INF = Float::INFINITY

  VELOCITIES = [
    'n', 'nn', 'nnn',
    'w', 'ww', 'www',
    's', 'ss', 'sss',
    'e', 'ee', 'eee'
  ]

  attr :row
  attr :col
  attr :velocity
  attr :cost_to_enter
  attr :goal

  attr_accessor :visited
  attr_accessor :distance

  class << self
    def make_stack(row, col, cost_to_enter)
      VELOCITIES.map { |v| Node.new(row, col, cost_to_enter, v)}
    end

    def world_at(row, col, velocity)
      if row.between?(0, $max_row - 1) && col.between?(0, $max_col - 1) && velocity.between?(0, VELOCITIES.length - 1)
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

    def shortest_unvisited_x
      result = nil
      $world.each do |r|
        r.each do |c|
          c.each do |n|
            if !n.visited && (result.nil? || n.distance < result.distance)
              result = n
            end
          end
        end
      end
      result
    end


  end

  def initialize(row, col, cost_to_enter, velocity)
    @distance = INF
    @visited = false

    @row = row
    @col = col
    @cost_to_enter = cost_to_enter
    @velocity = velocity
    @goal = row == $max_row - 1 && col == $max_col - 1
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
    three = letter * 3
    two = letter * 2
    one = letter

    nvelocity = case velocity
    when backwards, backwards * 2, backwards * 3 then -1 # no going backwards
    when three then -1 # can't go more than three in one direction
    when two  then VELOCITIES.index(three)
    when one   then VELOCITIES.index(two)
    else VELOCITIES.index(letter)
    end

    nrow = row + dr
    ncol = col + dc

    Node.world_at(nrow, ncol, nvelocity)
  end

end


infile = '17.txt'
# infile = '17_sample.txt'

$board = File.readlines(infile, chomp: true).map { | row | row.split('').map(&:to_i) }
$max_row = $board.length
$max_col = $board[0].length

$world = $board.each_with_index.map do |r, ri|
  r.each_with_index.map do |cost, ci|
    Node.make_stack(ri, ci, cost)
  end
end

# $world.each do |r|
#   r.each do |s|
#     s.each { |n| pinspect n }
#     puts ("")
#   end
#   puts ("-----")
# end

#create special origin node that has no initial velocity
origin = Node.new(0, 0, $board[0][0], '-')
origin.distance = 0

def print_world
  puts "\e[H\e[2J"
  $world.each do |r|
    r.each do |c|
      print("#{c.filter(&:visited).length.to_s(16)} ")
    end
    puts("")
  end
end

$touched = Set[]

current = origin
spax = 0
until (current.nil? || current.goal)
  spax += 1
  print_world if spax % 1000 == 0
  current.unvisited_neighbours.each do |n|
    this_dist = current.distance + n.cost_to_enter
    n.distance = this_dist if this_dist < n.distance
    $touched.add(n)
  end
  current.visited = true
  $touched.delete(current)
  current = Node.shortest_unvisited
end
pinspect current
