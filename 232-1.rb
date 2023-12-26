def pinspect(*args)
  puts *args.map(&:inspect)
end

X = 0
Y = 1
N = [-1,  0]
S = [ 1,  0]
E = [ 0,  1]
W = [ 0, -1]


class World
  attr :tiles
  attr :current
  attr :finished
  attr :success

  @@world_map

  class << self
    def set_world_map(m)
      @@world_map = m
    end
  end

  def initialize(tiles=nil, current=nil)
    if tiles.nil?
      @tiles = @@world_map.map { | r| r.map{ false } }
    else
      @tiles = tiles.map { |r| r.dup }
    end
    @current = if current.nil?
      [0, 1] # start pos
    else
      current
    end
    @finished = false
    @success = nil
  end

  def path_length
    @tiles.map do |r|
      r.map { |t| t ? 1 : 0}.sum
    end.sum
  end

  def set_current_visited
    @tiles[@current[X]][@current[Y]] = true
  end

  def tile_visited(pos)
    @tiles[pos[X]][pos[Y]]
  end

  def under_tile(pos)
    @@world_map[pos[X]][pos[Y]]
  end

  def offset_current(off)
    p = [@current[X] + off[X], @current[Y] + off[Y]]
    # puts ("offset: #{p.inspect}")
    p if p[X].between?(0, @tiles.length-1) && p[Y].between?(0, @tiles[0].length-1)
  end

  def end_pos
    [@tiles.length - 1, @tiles[0].length - 2]
  end

  def step
    set_current_visited
    if @current == end_pos  # we did it!
      @finished = true
      @success = true
    else
      nabes = get_current_visitable_neighbours
      if nabes.length == 0 # dead end
        @finished = true
        @success = false
      else
        @current = nabes.shift
        return nabes.map { |n| World.new(@tiles, n) }
      end
    end
    []
  end

  def get_current_visitable_neighbours
    potential = [N, S, W, E]
    potential.filter_map{ |offset| offset_current(offset)}.filter{ |t| !tile_visited(t) && under_tile(t) != '#' }
  end

  def print
    puts (@tiles.map do |row|
      row.map do |t|
        if @current && @current.pos == t.pos
          "⌘"
        elsif t.under == "#"
          "█"
        elsif %w[< > ^ v].include? t.under
          t.under
        elsif t.visited
          "."
        else
          " "
        end
      end.join('')
    end.join("\n"))
  end
end


# infile = '23_sample.txt'
infile = '23.txt'

# tiles = File.readlines(infile, chomp: true).each_with_index.map do | row, ridx |
#   row.split('').each_with_index.map do |t, cidx|
#     Tile.new(ridx, cidx, t)
#   end
# end

world_map = File.readlines(infile, chomp: true).map do | row |
  row.split('')
end

World.set_world_map(world_map)



multiverse = [World.new()]
success_runs = []


spax = 0
while multiverse.length > 0 do
  spax += 1
  if spax % 100 == 0
    puts ("Multiverse length: #{multiverse.length.to_s.rjust(4, ' ')} Successful runs: #{success_runs.length.to_s.rjust(4, ' ')}")
  end
  w = multiverse.shift
  until w.finished do
    multiverse.push(*w.step)
  end
  if w.success
    success_runs << w.path_length - 1
  end
end

pinspect success_runs.sort
