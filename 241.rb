def pinspect(*args)
  puts *args.map(&:inspect)
end

class Hail
  X = 0
  Y = 1
  Z = 2

  attr :input_line
  attr :start
  attr :veclocity

  def initialize(line)
    @input_line = line
    (@start, @velocity) = line.split('@').map{|x| x.split(',').map(&:to_f)}
  end

  def inspect
    "#<H:(#{@start}) --> (#{@velocity})>"
  end

  def mx
    @velocity[X]
  end

  def my
    @velocity[Y]
  end

  def bx
    @start[X]
  end

  def by
    @start[Y]
  end

  def xy_intersect_times(o)
    # (1) [x, y] = [m_x_1, m_y_1]*t + [b_x_1, b_y_1]
    # (2) [x, y] = [m_x_2, m_y_2]*s + [b_x_2, b_y_2]
    # [s, t] = 1/(m_x_1 * -m_y_2 + m_x_2 * m_y_1) * [(b_x_1 - b_x_2), (b_y_1, b_y_2)]
    # thanks stackoverflow
    denominator = (mx * o.my) - (o.mx * my)
    if denominator != 0
      [
        ((bx - o.bx) * ( -1 * o.my) - (by - o.by) * (-1 * o.mx)) / denominator,
        ((bx - o.bx) * ( -1 * my) - (by - o.by) * (-1 * mx)) / denominator,
      ]
    end
  end

  def xy_at(t)
    [bx + t * mx, by + t * my]
  end

  def xy_in_bounds_at(bounds, t)
    p = xy_at(t)
    p[X].between?(bounds[0][X], bounds[1][X]) &&
      p[Y].between?(bounds[0][Y], bounds[1][Y])
  end


end

# infile = "24_sample.txt"
infile = "24.txt"
$world = File.readlines(infile, chomp: true).map do |line|
  Hail.new(line)
end

bounds = [
  [200000000000000,200000000000000],
  [400000000000000, 400000000000000]

]

sum = 0
$world.combination(2) do |h1, h2|
  intersects = h1.xy_intersect_times(h2)
  if intersects && intersects.all?{|p| p >= 0} && h1.xy_in_bounds_at(bounds, intersects[0])
    puts("#{h1.inspect} * #{h2.inspect}")
    sum += 1
  end
end

puts("---")
puts(sum)

# ba + ma * t1 = b1 + m1 * t1
#   ba - b1 = m1 * t1 - ma * t1
#   ba - b1 = (m1 - ma) * t1

#   (ba - b1)
#   ---------    = t1
#   (m1 - ma )


#   (ba - b2)
#   ---------  = t1 + td1
#   (m2 - ma)

# ba + ma * t2 = b2 + m2 * t2
# ...
# ba + ma * tn = bn + mn * tn
