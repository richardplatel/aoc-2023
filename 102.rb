def pinspect(*args)
  puts *args.map(&:inspect)
end



pipe_connections = {
  '.' => [],
  '|' => [[-1,  0], [ 1,  0]],
  '-' => [[ 0, -1], [ 0,  1]],
  'L' => [[-1,  0], [ 0,  1]],
  'J' => [[-1,  0], [ 0, -1]],
  '7' => [[ 1,  0], [ 0, -1]],
  'F' => [[ 1,  0], [ 0,  1]],
}
ROW = 0
COL = 1


# pipe:from coords => [left hand neighbours]
PIPE_COLOR = {
  '|:-10' => [[ 0,  1]],
  '|:10'  => [[ 0, -1]],
  '-:0-1' => [[-1,  0]],
  '-:01'  => [[ 1,  0]],
  'L:01'  => [[ 1,  0], [ 1, -1], [ 0, -1]],
  'L:-10' => [],
  'J:-10' => [[ 0,  1], [ 1,  1], [ 1,  0]],
  'J:0-1' => [],
  '7:0-1' => [[-1,  0], [-1,  1], [ 0,  1]],
  '7:10'  => [],
  'F:10'  => [[-1,  0], [-1, -1], [ 0, -1]],
  'F:01'  => [],
}



# infile = "10_sample3.txt"
infile = "10.txt"
$world = File.readlines(infile, chomp: true).map do | l |
  l.split('')
end


# each node in wolrd connections is the list of nodes it's connected to (except 'S', we'll figure that out next).
$world_connections = $world.each_with_index.map do |row, row_idx |
  row.each_with_index.map do | pipe, col_idx |
      # puts "(#{row_idx}, #{col_idx}) -> #{pipe}"
      if pipe == 'S'
        S = [row_idx, col_idx]
        []
      else
        pipe_connections[pipe].map {|d| [row_idx + d[ROW], col_idx + d[COL]]}
      end
  end
end

# pinspect $world

def world_at(c)
  return $world_connections[c[ROW]][c[COL]]
end

# figure out what S is.
$world_connections[S[ROW]][S[COL]] =  [[-1, 0], [1, 0], [0, -1], [0, 1]].map do | d |
  neighbor = [S[ROW]+ d[ROW], S[COL] + d[COL]]
  # puts ("neighbor: #{neighbor}")
  if neighbor[ROW] >= 0 && neighbor[ROW] < $world_connections.length && neighbor[COL] >= 0 && neighbor[COL] < $world_connections[0].length && world_at(neighbor).include?(S)
    neighbor
  else
    nil
  end
end.compact

# $world_connections.each { |row| pinspect row}

$world_path = (0..$world_connections.length).map { (' ' * $world_connections[0].length).split('')}

def set_world_path_at(c, v)
  if c[ROW] >=0 && c[ROW] < $world_path.length && c[COL] >= 0 && c[COL] < $world_path[0].length
    $world_path[c[ROW]][c[COL]] = v
  end
end

def world_path_at(c)
  $world_path[c[ROW]][c[COL]]
end

def color_map(c, f)
  pipe = $world[c[ROW]][c[COL]]
  # set_world_path_at(c, pipe)
  set_world_path_at(c, '.')
  frow = f[ROW] - c[ROW]
  fcol = f[COL] - c[COL]
  key = "#{pipe}:#{frow}#{fcol}"
  # puts "from: #{f}, current: #{c} key: #{key}"
  PIPE_COLOR[key].each do |off|
    n = [ c[ROW] + off[ROW], c[COL]+ off[COL]]
    if world_path_at(n) == ' '
      # puts ("\t#{n}")
      set_world_path_at(n, '#')
    end
  end
  # puts "#{key} -> #{PIPE_COLOR[key]}"
  print_world_map
end

def print_world_map

  puts "\e[H\e[2J"
  puts ($world_path.map do |row|
    row.map { | c | "#{c}#{c}" }.join('')
  end.join("\n"))
  # $world_path.each_with_index { |row, i| puts "#{i}: #{row.join('')}" }
  sleep 0.005
  # puts ""
  # puts "----------------------"
  # puts ""
end


# current = s, from = random_connection, distance = 0
current = S
from = world_at(S)[1] # an arbitrary connection in to S
distance = 0

while true
  # find the connected neighbour that is not "from"
  neighbor = (world_at(current)- [from])[0]
  if neighbor == S
    break
  else
    from = current
    current = neighbor
    distance += 1
    color_map(current, from)
  end
end

# do fill
inside = false
(0...$world_path.length).each do | r |
  (0...$world_path[0].length).each do | c |
    node = [r, c]
    wpa = world_path_at(node)
    if inside
      if wpa == ' '
        set_world_path_at(node, "#")
      elsif wpa == '.'
        inside = false
      end
    else
      inside = true if wpa == '#'
    end
  end
  print_world_map
end

# countem

print_world_map
puts
puts "----------------"
puts $world_path.map { |r| r.count('#')}.sum




# puts ("path distance: #{distance}")
#puts ("furthest: #{(distance + 1) / 2}")

# $world_path.each { |row| pinspect row.join('')}
