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



class Point
  attr_accessor :row
  attr_accessor :col

  def initialize(row, col)
    @row = row
    @col = col
  end

  def to_a
    [@row, @col]
  end

  def inspect
    "<#{@row}, #{@col}>"
  end

  def +(obj)
    if obj.is_a?(Point)
      othr = obj.row
      othc = obj.col
    elsif obj.is_a?(Array)
      othr = obj[0]
      othc = obj[1]
    else
      raise "ouch"
    end
    Point.new(row + othr, col+ othc)
  end

  def determinant(other)
    @row * other.col - other.row * @col
  end

end


infile = '18.txt'
# infile = '18_sample.txt'

IDIRS = %w[R D L U]

$instructions = File.readlines(infile, chomp: true).map do | row |
  r = row.split(' ')
  code = r[2][2..-2].to_i(16)
  [ IDIRS[code % 0x10], code / 0x10]
  # puts code
  # [r[0], r[1].to_i]
end
pinspect $instructions

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

# origin
Point.new(min_row, min_col)
points = [Point.new(0, 0)]

perimeter = 0

$instructions.each do | i |
  (dir, dist) = i
  points << case dir
  when 'R' then points.last + [0, dist]
  when 'L' then points.last + [0, -1 * dist]
  when 'U' then points.last + [-1 * dist, 0]
  when 'D' then points.last + [dist, 0]
  end
  perimeter += dist
end

pinspect points


# shoelace
shoe = points.each_cons(2).map do |pair|
  pair[0].determinant(pair[1])
end.sum

pinspect shoe.abs/2 + perimeter/2 + 1
