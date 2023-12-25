def pinspect(*args)
  puts *args.map(&:inspect)
end

class Wire

  @@world

  attr :left
  attr :right
  attr_accessor :cut
  attr :group

  def initialize(side1, side2)
    (@left, @right) = [side1, side2].sort
    @cut = false
    @group = nil
  end

  def inspect
    "<W: #{@left}#{@cut ? "/" : "-"}#{@right}>"
  end

  def components
    [@left, @right]
  end


  def connected?(other)
    @left == other.left ||
    @left == other.right ||
    @right == other.left ||
    @right == other.right
  end

  class << self
    def set_world(world)
      @@world = world
    end

    def world
      @@world
    end

    def to_graphviz

      # strict graph {
      #   a -- b
      #   a -- b
      #   b -- a [color=blue]
      # }
      puts ("strict graph {")
      @@world.each do |w|
        puts("\t#{w.left} -- #{w.right}")
      end
      puts ("}")
    end

    def groups
      # for each wire
      #  find all the current groups it's a member of
      #  if 0 -> new group
      #  else merge those groups and << wire
      result = []
      @@world.each do |w|
        next if w.cut
        member, not_member = result.partition { |g| g.lazy.any?{|o| w.connected?(o)}}
        if member.length == 0
          result = not_member << [w]
        else
          result = not_member + [member.flatten << w]
        end
        # puts ("m: #{member.inspect}")
        # puts ("n: #{not_member.inspect}")
        # puts ("w: #{w.inspect}")
        # puts ("r: #{result.inspect}")
        # puts ("")
      end
      result
    end

    def components_in_group(g)
      g.flat_map(&:components).to_set
    end

  end
end






# infile = "25_sample.txt"
infile = "25.txt"

world = File.readlines(infile, chomp: true).flat_map do |line|
  (left, rest) = line.split(':')
  rest.split(" ").map { |r| Wire.new(left.to_sym, r.to_sym)}
end

Wire.set_world(world)

# do cuts
cuts = Wire.world.select do |w|
  [[:pzq, :rrz], [:jtr, :mtq], [:ddj, :znv]].include?(w.components)
end

pinspect cuts


cuts.each { |w| w.cut=true }
groups = Wire.groups
if groups.length == 2
  components = groups.map { |g| Wire.components_in_group(g)}
  puts components.map(&:length).inject(:*)
  pinspect cuts
end
cuts.each { |w| w.cut=false }
