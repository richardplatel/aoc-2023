def pinspect(*args)
  puts *args.map(&:inspect)
end


class Point

  @@field
  @@max_row
  @@max_col

  attr :row
  attr :col

  class << self
    def set_field(field)
      @@field = field
      @@max_row = field.length
      @@max_col = field[0].length
    end
  end

  def initialize(row, col)
    @row = row
    @col = col
  end

  def legal?
    @row.between?(0, @@max_row) && @col.between?(0, @@max_col)
  end

  def under
    @@field[@row][@col] if legal?
  end

  def offset_by(rx, cx)
    Point.new(@row + rx, @col + cx)
  end

  def reachable
    west  = [ 0, -1]
    east  = [ 0,  1]
    north = [-1,  0]
    south = [ 1,  0]

    [north, south, west, east].map do |o|
      p = offset_by(*o)
      p if p.legal? && p.under == '.'
    end.compact
  end


  def inspect
    "<P (#{@row}, #{@col})>"
  end

end

# infile = '211_sample.txt'
infile = '211.txt'

start = nil
field = File.readlines(infile, chomp: true).each_with_index.map do | r, ridx |
  r.split('').each_with_index.map do | v, cidx |
    if v == 'S'
      start = Point.new(ridx, cidx)
      v = '.'
    end
    v
  end
end

Point.set_field(field)
reachable_points = [start]

(0...13).each do
  reachable_points = reachable_points.flat_map do |rp|
    rp.reachable
  end
  reachable_points.uniq! {|p| [p.row, p.col]}
end
puts reachable_points.length
