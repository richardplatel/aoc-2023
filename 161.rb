def pinspect(*args)
  puts *args.map(&:inspect)
end

ROW = 0
COL = 1
RIGHT = [ 0,  1]
LEFT =  [ 0, -1]
UP =    [-1,  0]
DOWN =  [ 1,  0]

class Beam
  class << self
    def step(beam)
      if beam.move_to_next_pos
        # if ! $board_visits[beam.row][beam.col].include?(beam.direction)
        #   $board_visits[beam.row][beam.col] << beam.direction
        if true
          $board_visits[beam.row][beam.col] = ["X"]


          case beam.under
          when '.' then [beam]
          when '|'
            if [UP, DOWN].include? beam.direction
              [beam]
            else
              beam.direction = UP
              [beam, Beam.new(beam.position, DOWN)]
            end
          when '-'
            if [LEFT, RIGHT].include? beam.direction
              [beam]
            else
              beam.direction = LEFT
              [beam, Beam.new(beam.position, RIGHT)]
            end
          when '\\'
            beam.direction = case beam.direction
            when LEFT then UP
            when RIGHT then DOWN
            when UP then LEFT
            when DOWN then RIGHT
            end
            [beam]
          when '/'
            beam.direction = case beam.direction
            when LEFT then DOWN
            when RIGHT then UP
            when UP then RIGHT
            when DOWN then LEFT
            end
            [beam]
          end
        end
      end
    end
  end
  attr_accessor :position, :direction

  def initialize(position, direction)
    @position = position
    @direction = direction
  end

  def row
    @position[ROW]
  end

  def col
    @position[COL]
  end

  def dir_row
    @direction[ROW]
  end

  def dir_col
    @direction[COL]
  end

  def move_to_next_pos
    p = [row+dir_row, col+ dir_col]
    if p[0].between?(0, $max_row -1) && p[1].between?(0, $max_col -1)
      @position = p
    else
      @position = nil
    end
    @position
  end

  def under
    $board[row][col] if position
  end

  def to_s
    case @direction
    when RIGHT then '>'
    when LEFT  then '<'
    when UP    then '^'
    when DOWN  then 'v'
    end
  end

  def eql?(other)
    puts "Hi"
    @position == other.position
    @direction == other.direction
  end
end


def print_board(animate: true)
  puts "\e[H\e[2J" if animate
  brd = $board.map { |r| r.dup }
  $board_visits.each_with_index { |r, ri| r.each_with_index { |v, ci| brd[ri][ci] = 'X' if v.any? }}
  $beams.each do |b|
     brd[b.row][b.col] = b.to_s
  end

  brd.each do |r|
    puts(r.join.gsub('.', ' '))
  end
  sleep 0.5 if animate
end

def count_energized
  $board_visits.map do |row|
    row.filter { |r| !r.empty? }.count
  end.sum
end

# infile = '161_sample.txt'
infile = '161.txt'

$board = File.readlines(infile, chomp: true).map { | row | row.split('') }
$max_row = $board.length
$max_col = $board[0].length



$board_visits = (0...$max_row).map { (0...$max_col).map { [] }}

#pinspect $board_visits

# [ [location, direction] ]
$beams = [Beam.new([0,0], RIGHT)]
$board_visits[0][0] << RIGHT

# pinspect $beams
# print_board
until $beams.empty?
  $beams = $beams.flat_map { |b| Beam.step(b) }.compact
  $beams = $beams.uniq { |b| "#{b.position}#{b.direction}"}
  puts "\e[H\e[2J"
  puts $beams.length
  puts count_energized
  puts ("---")
  # print_board
end

# $board_visits.each { |row| pinspect row}

c = $board_visits.map do |row|
  row.filter { |r| !r.empty? }.count
end.sum

puts "c: #{c} #{$max_row} x #{$max_col} #{c * 100 / ($max_row * $max_col)}%"

# 7183
