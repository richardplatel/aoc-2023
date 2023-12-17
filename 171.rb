def pinspect(*args)
  puts *args.map(&:inspect)
end

class Node
  INF = Float::INFINITY
  BIG = 1000
  attr_accessor :visited
  attr_accessor :tentative_distance
  attr :row
  attr :col
  attr :north_distance
  attr :south_distance
  attr :east_distance
  attr :west_distance
  attr :goal

  def initialize(row, col)
    @row = row
    @col = col
    @visited = false
    @tentative_distance = INF

    # north, south, east, west neighbour co-ords
    @nnc = [@row - 1, @col]
    @snc = [@row + 1, @col]
    @wnc = [@row, @col - 1]
    @enc = [@row, @col + 1]

    @north_distance = distance_at(*@nnc)
    @south_distance = distance_at(*@snc)
    @west_distance  = distance_at(*@wnc)
    @east_distance  = distance_at(*@enc)
    @goal = row == $max_row - 1 && col == $max_col - 1
  end

  def unvisited_neighbours
    # if we're considering going w, and the only shortest
    # path to this node is from w and only www, increase
    # the cost.
    costly = costly_direction
    [
      [@nnc, @north_distance, 'n'],
      [@snc, @south_distance, 's'],
      [@wnc, @west_distance,  'w'],
      [@enc, @east_distance,  'e'],
    ].map do |n|
      candidate = board_at(*n[0])
      if candidate && !candidate.visited
        [candidate, n[2] == costly ? BIG : n[1]]
      end
    end.compact
  end

  def costly_direction
    bp = backpaths
    # if we're considering going w, and the only shortest
    # path to this node is from w and only www, increase
    # the cost.
    if bp.length == 1
      case bp[0]
      when 'nnn' then 'n'
      when 'sss' then 's'
      when 'www' then 'w'
      when 'eee' then 'e'
      end
    end
  end

  def backpaths
    b1 = backtracks
    b2 = b1.flat_map { |b| b[0].backtracks.map { |bb| [b, bb]}}
    b3 = b2.flat_map { |b| b.last[0].backtracks.map { |bb| b + [bb]}}
    b3.map { |p| p.map { |b| b[1]}.join}
  end

  def backtracks
    came_from = ['s', 'n', 'e', 'w']
    nodes = [@nnc, @snc, @wnc, @enc].map{ |d| board_at(*d)}.map{|n| n if (n && n.visited && n.tentative_distance < tentative_distance) }
    distances = nodes.map { |n| n ? n.tentative_distance : INF}
    min = distances.min
    nodes.each_with_index.map { |n, i| [n, came_from[i]] if n && distances[i] && distances[i] == min}.compact
  end

  def distance_at(row, col)
    if row.between?(0, $max_row - 1) && col.between?(0, $max_col - 1)
      $distances[row][col]
    end
  end

  def board_at(row, col)
    if row.between?(0, $max_row - 1) && col.between?(0, $max_col - 1)
      $board[row][col]
    end
  end

  def inspect
    "<NODE (#{row.to_s.rjust(3, '0')}, #{col.to_s.rjust(3, '0')}) #{visited ? "V" : " "} #{tentative_distance}>"
  end

end

def print_board
  $board.each do |r|
    r.each do |n|
      td = n.tentative_distance
      o = if td == Node::INF
        'i'
      else
        td.to_s
      end
      print " #{o.rjust(4,' ')}#{n.visited ? "." : " "}"
    end
    puts ("")
  end
  puts ("")
end

def smallest_unvisited
  # implement some heuristics here?  max row explored, max col explored?
  node = nil
  $board.each do |r|
    r.each do | n |
      if ! n.visited && (node.nil? || n.tentative_distance < node.tentative_distance)
        node = n
      end
    end
  end
  node
end


$infile = '17_sample.txt'
$distances = File.readlines($infile, chomp: true).map { | row | row.split('').map(&:to_i) }
$max_row = $distances.length
$max_col = $distances[0].length

# $distances.each { |r| pinspect r}

$board = $distances.each_with_index.map do | row, row_idx |
  row.each_with_index.map do | n, col_idx |
    Node.new(row_idx, col_idx)
  end
end

current = $board[0][0]
current.tentative_distance = 0

# pinspect current.backpath


until (current.nil? || current.goal)
  current.unvisited_neighbours.each do |uv|
    (node, edge_distance) = *uv
    # puts ("ed: #{edge_distance}")
    # puts ("__")
    new_distance = current.tentative_distance + edge_distance
    node.tentative_distance = new_distance if new_distance < node.tentative_distance
  end
  current.visited = true
  pinspect current
  print_board
  if current.tentative_distance > 1000
    puts ("oof!")
    break
  end
  current = smallest_unvisited
  # puts ("Next Node: #{current.row}, #{current.col}")
  # print_board
end

# print_board
