def pinspect(*args)
  puts *args.map(&:inspect)
end

def print_board
  puts "\e[H\e[2J"
  $board.each do |r|
    puts r.join
  end
end

def set_board_at(row, col, value='#')
  $board[row][col] = value
end

def board_at(row, col)
  return nil unless row.between?(0, $max_row - 1) && col.between?(0, $max_col - 1)
  $board[row][col]
end

def flood_fill(start)
  queue = [start]
  spax = 0
  while ((p = queue.pop) != nil)
    # spax += 1
    # print_board if spax % 100 == 0
    # pinspect queue
    if board_at(*p) == '.'
      set_board_at(*p, '#')
      queue << [p[0] + 1, p[1]]
      queue << [p[0] - 1, p[1]]
      queue << [p[0], p[1] + 1]
      queue << [p[0], p[1] - 1]
    end
    # print_board
  end
end





infile = '18.txt'
# infile = '18_sample.txt'

$instructions = File.readlines(infile, chomp: true).map do | row |
  r = row.split(' ')
  [ r[0], r[1].to_i, r[2] ]
end

# figure out extents
$max_row = 0
$max_col = 0
min_row = 0
min_col = 0
current = [0, 0]

$instructions.each do | i |
  (dir, dist, colour) = i
  case dir
  when 'R' then current[1] += dist
  when 'L' then current[1] -= dist
  when 'U' then current[0] -= dist
  when 'D' then current[0] += dist
  end

  $max_row = current[0] if current[0] > $max_row
  min_row = current[0] if current[0] < min_row
  $max_col = current[1] if current[1] > $max_col
  min_col = current[1] if current[1] < min_col

  # puts "@(#{current[0]}, #{current[1]}), (#{min_row}, #{min_col}) -> (#{$max_row}, #{$max_col})"
end

# transform origin and create big-enough board
row_off = -1 * min_row
col_off = -1 * min_col


$max_row = $max_row + row_off
$max_col = $max_col + col_off

$board = (0..$max_row).map do |r|
  (0..$max_col).map { |c| '.'}
end

current = [row_off, col_off]

# draw path
set_board_at(*current)
# print_board

$instructions.each do | i |
  (dir, dist, colour) = i
  move = case dir
  when 'R' then [0, 1]
  when 'L' then [0, -1]
  when 'U' then [-1, 0]
  when 'D' then [1, 0]
  end

  (1..dist).each do |i|
    current[0] += move[0]
    current[1] += move[1]
    set_board_at(*current, '#')
  end
  # print_board
end

a_point_that_is_definitely_inside = [$max_row / 2, $max_col / 2]
flood_fill(a_point_that_is_definitely_inside)

print_board
puts $board.map{ |r| r.count('#')}.sum
