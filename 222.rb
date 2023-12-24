require "rmagick"
def pinspect(*args)
  puts *args.map(&:inspect)
end


class Brick
  X = 0
  Y = 1
  Z = 2

  DRAW_SCALE = 10

  COLORS = File.readlines("colors.txt", chomp: true).to_a
  @@extents = [0, 0, 0]
  @@bricks = []

  attr :corner1
  attr :corner2
  attr :color
  attr_accessor :drop_count


  def initialize(c1, c2)
    # make corner 1 always the closest to 0, 0, 0
    # since bricks are always lines of cubes, only
    # one co-ordinate is ever different
    @corner1 = c1.zip(c2).map(&:min)
    @corner2 = c1.zip(c2).map(&:max)
    @color = COLORS.sample
    @@extents = @@extents.zip(c2).map(&:max)
    @hidden = false
  end

  def hide
    @hidden = true
  end

  def unhide
    @hidden = false
  end

  def hidden?
    @hidden
  end

  def xy_intersect(other)
    # Two bricks overlap if the x-ranges overlap and the y-ranges overlap
    other.corner1[X] <= @corner2[X] && @corner1[X] <= other.corner2[X] &&
    other.corner1[Y] <= @corner2[Y] && @corner1[Y] <= other.corner2[Y]
  end

  def bricks_above
    # cache this?
    level = @corner2[Z] + 1
    Brick.bricks_at_zlevel(level).select { |b| xy_intersect(b) }
  end

  def could_drop()
    to_level = @corner1[Z] - 1
    (to_level > 0) && Brick.bricks_at_zlevel(to_level).none? { |b| b != self && !b.hidden? && xy_intersect(b) }
  end

  def drop_once
    if could_drop
      @corner1[Z] -= 1
      @corner2[Z] -= 1
      true
    else
      false
    end
  end

  def xz_rect
    [@corner1.values_at(X, Z), @corner2.values_at(X, Z)]
  end

  def yz_rect
    [@corner1.values_at(Y, Z), @corner2.values_at(Y, Z)]
  end

  def xy_rect
    [@corner1.values_at(X, Y), @corner2.values_at(X, Y)]
  end

  class << self
    def extents
      @@extents
    end

    def bricks
      @@bricks
    end

    def set_world(bricks)
      @@bricks = bricks.sort_by { |b| b.corner1[X] + b.corner1[Y] * 100 + b.corner1[Z] * 10000 }
    end

    def bricks_at_zlevel(level)
      @@bricks.filter { |b| level.between?(b.corner1[Z], b.corner2[Z])}
    end

    def unhide_all
      @@bricks.each(&:unhide)
    end

    def draw_bricks(filename="foo.png")
      canvas = Magick::ImageList.new

      draw_frame(canvas)
      canvas.write(filename)
    end


    def draw_frame(canvas)
      width = (1 + @@extents[X] + 1 + 1 + @@extents[Y] + 1 + 1 + @@extents[X] + 1 + 1) * DRAW_SCALE
      height = (@@extents[Z] + 2) * DRAW_SCALE

      canvas.new_image(width, height, Magick::HatchFill.new('white', 'gray90', DRAW_SCALE))

      stuff = Magick::Draw.new
      stuff.stroke("black")
      stuff.stroke_width(1)

      xz_origin = [1, 1]
      @@bricks.each do |b|  # to do, need to order these by y-order ?
        stuff.fill(b.color)
        xz = b.xz_rect
        stuff.rectangle(
          (xz_origin[X] + xz[0][X]) * DRAW_SCALE,
          (xz_origin[Y] + xz[0][Y]) * DRAW_SCALE,
          (xz_origin[X] + xz[1][X] + 1) * DRAW_SCALE,
          (xz_origin[Y] + xz[1][Y] + 1) * DRAW_SCALE,
        )
      end

      yz_origin = [xz_origin[X] + 1 + 1 + @@extents[X], 1]
      @@bricks.each do |b|  # to do, need to order these by x-order ?
        stuff.fill(b.color)
        yz = b.yz_rect
        stuff.rectangle(
          (yz_origin[X] + yz[0][X]) * DRAW_SCALE,
          (yz_origin[Y] + yz[0][Y]) * DRAW_SCALE,
          (yz_origin[X] + yz[1][X] + 1) * DRAW_SCALE,
          (yz_origin[Y] + yz[1][Y] + 1) * DRAW_SCALE,
        )
      end


      xy_origin = [yz_origin[X] + 1 + 1 + @@extents[Y], 2]
      @@bricks.each do |b|  # to do, need to order these by z-order ?
        stuff.fill(b.color)
        xy = b.xy_rect
        stuff.rectangle(
          (xy_origin[X] + xy[0][X]) * DRAW_SCALE,
          (xy_origin[Y] + xy[0][Y]) * DRAW_SCALE,
          (xy_origin[X] + xy[1][X] + 1) * DRAW_SCALE,
          (xy_origin[Y] + xy[1][Y] + 1) * DRAW_SCALE,
        )
      end

      stuff.draw(canvas)
      canvas.flip!
    end
  end

end

# infile = '22_dbg.txt'
# infile = '22_sample.txt'
infile = '22.txt'


bricks = File.readlines(infile, chomp: true).each_with_index.map do | line, lidx |
  (x1, y1, z1, x2, y2, z2) = line.split(/[,~]/).map(&:to_i)
  Brick.new([x1, y1, z1], [x2, y2, z2])
end

Brick.set_world(bricks)
# Brick.draw_bricks()

# canvas = Magick::ImageList.new
# Brick.draw_frame(canvas)

puts "Dropping #{Brick.bricks.length} bricks"
# Brick.bricks.each { |b| pinspect b}
spax = 0
Brick.bricks.each do |b|
  # puts (" Checking #{b.inspect}")
  spax += 1
  if spax % 100 == 0
    puts ("#{spax} bricks...")
  end
  while b.drop_once do
    true
  end
  # Brick.draw_frame(canvas)
  # pinspect b
end


puts "Checking #{Brick.bricks.length} bricks"
spax = 0
Brick.bricks.each do |b|
  spax += 1
  if spax % 100 == 0
    puts ("#{spax} bricks...")
  end
  b.hide
  b.drop_count = 0
  to_check = b.bricks_above
  # to_check.each { | b2 | puts("above   #{b2.inspect}") }
  while (to_check.length > 0)
    b2 = to_check.shift
    next if b2.hidden?
    if b2.could_drop
      b.drop_count += 1
      b2.hide
      to_check += b2.bricks_above
    end
  end
  Brick.unhide_all
end

puts ("---")
puts Brick.bricks.map(&:drop_count).sum



#   b2 = b.supporting.shift
#   if b2.could_drop
#    count += 1
#    b2.hide
#    to_check < b2.supporting
#   end
#

# puts ("Drop counts")
# Brick.bricks.reverse.each do |b|
#   puts ("#{b.inspect}: #{b.drop_count}")
# end
# canvas.write("foo.gif")

# # Brick.draw_bricks('bar.png')


# puts ("")
# puts ("")
# puts ("Done dropping, zapping #{Brick.bricks.length} bricks ")
# # Brick.bricks.each { |b| pinspect b}
# spax = 0
# zappable = Brick.bricks.map do |b|
#   spax += 1
#   if spax % 100 == 0
#     puts ("#{spax} bricks...")
#   end
#   # puts ("Checking #{b.inspect}")
#   orig_z = b.corner2[Brick::Z]
#   b.corner2[Brick::Z] += 1000
#   b.corner1[Brick::Z] += 1000

#   zap =  Brick.bricks_at_zlevel(orig_z + 1).none?(&:could_drop)
#   b.corner2[Brick::Z] -= 1000
#   b.corner1[Brick::Z] -= 1000
#   b if zap
# end.compact

# puts ("Zappable")
# zappable.each { |b| puts ("  #{b.inspect}")}
# puts ("---")
# puts ("#{zappable.length}")






# # (0..Brick.extents[Brick::Z]).each do | level |
# #   puts ("Level: #{level}")
# #     Brick.bricks_at_zlevel(level).each { |b| puts ("  #{b.inspect}") }
# # end
