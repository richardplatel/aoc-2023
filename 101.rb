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

infile = "10.txt"
world = File.readlines(infile, chomp: true).map do | l |
  l.split('')
end


# each node in wolrd connections is the list of nodes it's connected to (except 'S', we'll figure that out next).
$world_connections = world.each_with_index.map do |row, row_idx |
  row.each_with_index.map do | pipe, col_idx |
      puts "(#{row_idx}, #{col_idx}) -> #{pipe}"
      if pipe == 'S'
        S = [row_idx, col_idx]
        []
      else
        pipe_connections[pipe].map {|d| [row_idx + d[ROW], col_idx + d[COL]]}
      end
  end
end

pinspect world

def world_at(c)
  return $world_connections[c[ROW]][c[COL]]
end

# figure out what S is.
$world_connections[S[ROW]][S[COL]] =  [[-1, 0], [1, 0], [0, -1], [0, 1]].map do | d |
  neighbor = [S[ROW]+ d[ROW], S[COL] + d[COL]]
  puts ("neighbor: #{neighbor}")
  if neighbor[ROW] >= 0 && neighbor[ROW] < $world_connections.length && neighbor[COL] >= 0 && neighbor[COL] < $world_connections[0].length && world_at(neighbor).include?(S)
    puts ("X")
    neighbor
  else
    nil
  end
end.compact

$world_connections.each { |row| pinspect row}


# current = s, from = random_connection, distance = 0
current = S
from = world_at(S)[0] # an arbitrary connection in to S
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
  end
end

puts ("path distance: #{distance}")
puts ("furthest: #{(distance + 1) / 2}")
