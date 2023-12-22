def pinspect(*args)
  puts *args.map(&:inspect)
end


class Point

  @@field
  @@max_row
  @@max_col

  attr :row
  attr :col
  attr_accessor :reachable_in
  attr :under

  class << self
    def create_field(field)
      @@field = field.each_with_index.map do | row, ri|
        row.each_with_index.map do | u, ci |
          Point.new(ri,ci,u)
        end
      end
      # XXX these should not be minus 1 if modding?
      @@max_row = field.length - 1
      @@max_col = field[0].length - 1
    end

    def field_at(r, c)
      @@field[r][c] if r.between?(0, @@max_row) && c.between?(0, @@max_col)
    end

    def print_field
      @@field.each do | row |
        puts row.map { | p | p.plot? ? (p.reachable_in ? "#{p.reachable_in.to_s.rjust(3,' ')}" : "nil"): ' # ' }.join(' ')
      end
    end


  end

  def initialize(row, col, under)
    @row = row
    @col = col
    @under = under
    @reachable_in = []
  end

  def plot?
    under != '#'
  end

  def field_at_offset(rx, cx)
    Point.field_at(@row + rx, @col + cx)
  end

  def explore_nabes
    west  = [ 0, -1]
    east  = [ 0,  1]
    north = [-1,  0]
    south = [ 1,  0]

    distance = @reachable_in + 1

    [north, south, west, east].filter_map {|d| field_at_offset(*d) }.select(&:plot?).map do |p|
      if p.reachable_in.lazy.none? { |fac| distance % fac == 0}
        p.reachable_in << distance
        p
      end
    end.compact
  end

  def inspect
    "<P #{under} #{@reachable_in || "?"} (#{@row}, #{@col})>"
  end


end

# infile = '211_sample.txt'
infile = '211.txt'
# infile = '211x.txt'

start_coords = nil
field = File.readlines(infile, chomp: true).each_with_index.map do | r, ridx |
  r.split('').each_with_index.map do | v, cidx |
    if v == 'S'
      v = '.'
      start_coords = [ridx, cidx]
    end
    v
  end
end

Point.create_field(field)
start = Point.field_at(*start_coords)
start.reachable_in = [0]

explorable_points = [start]

# XXX global step count pass to explore_nabes??!
while explorable_points.length > 0
  # pinspect explorable_points
  p = explorable_points.shift
  explorable_points.append(*p.explore_nabes)
end

Point.print_field

# (0...64).each do
#   reachable_points = reachable_points.flat_map do |rp|
#     rp.reachable
#   end
#   reachable_points.uniq! {|p| [p.row, p.col]}
# end
# puts reachable_points.length


# 26501365
# Factorization: 5 * 11 * 481843
