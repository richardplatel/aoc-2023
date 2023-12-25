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
    (@start, @velocity) = line.split('@').map{|x| x.split(',').map(&:to_i)}
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

  def mz
    @velocity[Z]
  end

  def bx
    @start[X]
  end

  def by
    @start[Y]
  end

  def bz
    @start[Z]
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

  def vel_str(x)
    if x == 1
      "+ "
    elsif x >= 0
      "+ #{x}"
    else
      "- #{x.abs}"
    end
  end

  def xsquasion(t)
    [
      "x + a#{t} = #{bx} #{vel_str(mx)}#{t}",
      "y + b#{t} = #{by} #{vel_str(my)}#{t}",
      "z + c #{t} = #{bz} #{vel_str(mz)}#{t}",
    ]
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

tvars = ['t', 'u', 'v']

out = tvars.each_with_index.map do | t, i |
  $world[i].xsquasion(t).join("\n")
end.join("\n")

puts(out)
