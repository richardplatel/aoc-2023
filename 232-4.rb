require 'ruby-graphviz'

X = 0
Y = 1
N = [-1,  0]
S = [ 1,  0]
E = [ 0,  1]
W = [ 0, -1]


class Node
  attr :name
  attr :original_pos
  attr_accessor :edges # { node_name => steps }
  attr_accessor :initial_edge_count
  attr_accessor :visited

  def initialize(pos)
    @original_pos = pos
    @name = Node.node_name(pos)
    @edges = {}
    @visited = false
  end

  def ddup
    ret = Node.new(@original_pos)
    ret.visited = @visited
    ret.initial_edge_count = @initial_edge_count
    ret.edges = @edges.dup
    ret
  end

  def add_edge(other, steps)
    @edges[other.name] = [steps, @edges.fetch(other.name, 0)].max
  end

  def lock_in_edge_count
    @initial_edge_count = @edges.length
  end

  def leaf?
    @edges.length == 1
  end

  class << self
    def node_name(pos)
      "#{pos[X].to_s.rjust(3, '0')}-#{pos[Y].to_s.rjust(3, '0')}"
    end
  end
end

class World

  @@world_tiles
  class << self
    def set_world_tiles(tiles)
      @@world_tiles = tiles
    end

    def tile_at_pos(pos, offset=[0, 0])
      p = [pos[X] + offset[X], pos[Y] + offset[Y]]
      if p[X].between?(0, @@world_tiles.length - 1) && p[Y].between?(0, @@world_tiles[0].length - 1)
        @@world_tiles[p[X]][p[Y]]
      end
    end

    def neighbour_tile_positions(pos)
      [N, S, E, W].map { | off | p = [pos[X] + off[X], pos[Y] + off[Y]] }.select { |n| tile_at_pos(n) != nil and tile_at_pos(n) != '#'}
    end
  end



  attr :nodes #{nodename => node}
  attr :finished
  attr :success
  attr_accessor :current_node
  attr :path_length

  def initialize(nodes=nil, current_node_name=nil, path_length=0)

    @finished = false
    @success = nil
    @path_length = path_length
    @nodes = {}

    if nodes
      @nodes = nodes.map do |node_name, n |
        [node_name, n.ddup]
      end.to_h
    end
    @current_node = nil
    if current_node_name
      @current_node = @nodes[current_node_name]
     #  puts ("#{current_node_name} --> current node: #{current_node.inspect}")
    end
  end
  
  def node_visited_pct
    (@nodes.values.count(&:visited) * 100) / @nodes.length
  end

  def end_node(n)
    n.original_pos == [@@world_tiles.length - 1, @@world_tiles[0].length - 2]
  end

  def step
    @current_node.visited = true
    # @path_length += 1
    if end_node(@current_node) # we did it!
      @finished = true
      @success = true
    else

      nabes = @current_node.edges.to_a.filter {|p| ! @nodes[p[0]].visited }
      # puts "#{@current_node.name} nabes: #{nabes.inspect}"
      if nabes.length == 0 # dead end
        @finished = true
        @success = false
      else
        me = nabes.shift
        ret = nabes.map { |n| World.new(@nodes, n[0], @path_length + n[1]) }
        @current_node = @nodes[me[0]]
        @path_length += me[1]
        return ret
      end
    end
    []
  end

  def to_dot
      edges = @nodes.values.flat_map do |n|
        n.edges.map do |o, w|
          edge = [n.name, @nodes[o].name].sort.map{|n| "\"#{n}\""}.join(" -- ")
          "\t #{edge} [label=\"#{w}\"]"
        end
      end

      edges = edges.sort.uniq
      "graph G {\n" +
      edges.join("\n") +
      "\n}\n"
  end

  def node_at(pos)
    @nodes[Node.node_name(pos)]
  end

  def create_node(pos)
    n = Node.new(pos)
    @nodes[n.name] = n
  end

  def add_edges(n1, n2, steps)
    if !n1.nil? && !n2.nil?
      n1.add_edge(n2, steps)
      n2.add_edge(n1, steps)
    end
  end

  # Start with the map and make a node per tile with edge weights 1
  def explore_map(map_position, previous_node)
    while true
      # puts("Hello mp: #{map_position.inspect} prev: #{previous_node.inspect}")
      if node_here = node_at(map_position)
        add_edges(node_here, previous_node, 1)
        return
      else
        node_here = create_node(map_position)
        add_edges(node_here, previous_node, 1)
        nabes = World.neighbour_tile_positions(map_position).filter{|n| !previous_node || n != previous_node.original_pos}
        return unless nabes.any?
        map_position = nabes.shift
        previous_node = node_here
        nabes.each { |n| explore_map(n, previous_node)}
      end
    end
  end

  def simplifiable?(node)
    node.initial_edge_count == 2 && node.edges.keys.none? { |name| @nodes[name].leaf?}
  end

  def simplify
    @nodes.values.each(&:lock_in_edge_count)
    while node = @nodes.values.find { |n| simplifiable?(n)}
      # puts ("simplifying #{node.inspect}")
      (ls_name, ls_weight, rs_name, rs_weight) = node.edges.to_a.flatten
      ls = @nodes[ls_name]
      rs = @nodes[rs_name]
      add_edges(ls, rs, ls_weight + rs_weight)
      # delete_node(node)
      ls.edges.delete(node.name)
      rs.edges.delete(node.name)
      @nodes.delete(node.name)
      # puts ("left side: #{ls.inspect}")
      # puts ("right side: #{rs.inspect}")
      # puts ("")
    end
  end

end





infile = "23.txt"
# infile = "23_dbg.txt"
# infile = "23_sample.txt"
world_tiles = File.readlines(infile, chomp: true).map do | row |
  row.split('')
end

World.set_world_tiles(world_tiles)
w = World.new
start = [0, 1]
w.explore_map(start, nil)
w.simplify
# puts w.to_dot

w.current_node = w.node_at([0, 1])

multiverse = [w]
success_runs = []

spax = 0
while multiverse.length > 0 do
  spax += 1
  puts("MVL: #{multiverse.length} Successes: #{success_runs.length} #{success_runs.max} p: #{multiverse.first.node_visited_pct} %") if spax % 1000 == 0
  w = multiverse.shift
  until w.finished do
    multiverse.push(*w.step)
    # puts ("MVlen: #{multiverse.length}")
  end
  # puts ("xxxxxxxxxxxxxxx")
  if w.success
    success_runs << w.path_length
  end
end

puts ("---")
puts success_runs.sort.inspect
