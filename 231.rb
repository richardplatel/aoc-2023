def pinspect(*args)
  puts *args.map(&:inspect)
end

X = 0
Y = 1
N = [-1,  0]
S = [ 1,  0]
E = [ 0,  1]
W = [ 0, -1]

class Tile

  attr :pos
  attr :under
  attr_accessor :visited

  def initialize(x, y, under, visited=false)
    @pos = [x, y]
    @under = under
    @visited = visited
  end

  def ddup
    return Tile.new(@pos[X], @pos[Y], @under, @visited)
  end

end

class World
  attr :tiles
  attr :current
  attr :path_length
  attr :finished
  attr :success

  def initialize(tiles, current=nil, path_length=0)
    @tiles = tiles.map { |r| r.map {|t| t.ddup }}
    cpos = if current.nil?
      [0, 1] # start pos
    else
      current.pos
    end
    @current = tile_at(cpos)
    @path_length = path_length
    @finished = false
    @success = nil
  end

  def tile_at(pos)
    if pos[X].between?(0, @tiles.length-1) && pos[Y].between?(0, @tiles[0].length-1)
      @tiles[pos[X]][pos[Y]]
    end
  end

  def offset_current(off)
    p = [@current.pos[X] + off[X], @current.pos[Y] + off[Y]]
    tile_at(p)
  end

  def end_pos
    [@tiles.length - 1, @tiles[0].length - 2]
  end

  def step
    @current.visited = true
    @path_length += 1
    if @current.pos == end_pos  # we did it!
      @finished = true
      @success = true
    else
      nabes = get_current_visitable_neighbours
      # pinspect nabes
      if nabes.length == 0 # dead end
        @finished = true
        @success = false
      else
        @current = nabes.shift
        return nabes.map { |n| World.new(@tiles, n, @path_length) }
      end
    end
    []
  end

  def get_current_visitable_neighbours

    potential = case @current.under
    when '<'
       [W]
    when '>'
       [E]
    when '^'
       [N]
    when 'v'
       [S]
    else
      [N, S, W, E]
    end

    potential.filter_map{ |offset| offset_current(offset)}.filter{ |t| !t.visited && t.under != '#' }
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


infile = '23.txt'

tiles = File.readlines(infile, chomp: true).each_with_index.map do | row, ridx |
  row.split('').each_with_index.map do |t, cidx|
    Tile.new(ridx, cidx, t)
  end
end

multiverse = [World.new(tiles)]

while w = multiverse.find{ |wx| ! wx.finished }
  multiverse.push(*w.step)
  puts "\e[H\e[2J"
  puts ("Multiverse size: #{multiverse.length}")
  puts ("Multiverse path_lengths: #{multiverse.map(&:path_length).join(', ')}")
  puts ("Multiverse finished: #{multiverse.map(&:finished).join(', ')}")
  # w.print
  # sleep(0.01)
end

successful_worlds = multiverse.select(&:success)
puts ("Successful path lengths: ")
puts successful_worlds.map(&:path_length).join (", ")
best_of_all_possible_worlds = multiverse.select(&:success).max { |a, b| a.path_length <=> b.path_length }
best_of_all_possible_worlds.print
puts (best_of_all_possible_worlds.path_length - 1)
