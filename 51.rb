def pinspect(*args)
  puts *args.map(&:inspect)
end


# [part_no, start_idx, end_idx]

almanac = []
File.readlines("51.txt", chomp: true).each do |line|
  almanac.append(line)
end


maps = []
this_map = []
almanac.each do |line|
  range = line.scan(/\d+/).map(&:to_i)
  if range.length > 0
    this_map << range
  else
    if this_map.length > 0
      maps << this_map
      this_map = []
    end
  end
end
maps << this_map

seeds = maps.shift[0]

# [destination_start, source_start, range] -> [source_min, source_max+1, offset]
maps = maps.map do |m|
  m.map { |r| [r[1], r[1] + r[2], r[0] - r[1]] }
end

# x is between a and b, inclusive of a and exclusive of b
def betwixt(x, a, b)
  if a < b
    x >= a && x < b
  else
    x <= a && x > b
  end
end

def apply_map(source, map)

  map.each do |r|
    if betwixt(source, r[0], r[1])
      source += r[2]
      break
    end
  end
  source
end


min = nil
# pinspect seeds
# maps.each do |m |

#   seeds = seeds.map { |s| apply_map(s, m)}
#   pinspect seeds
# end

seeds.each_slice(2) do |start, range|
  puts ("Start: #{start}, Range: #{range}")
  (start...start+range).each do |location|
    maps.each do |m|
      location = apply_map(location, m)
    end
    if min.nil? || location < min
      min = location
    end
  end
  puts ("Min so far: #{min}")
end

puts min

# seed = 14
# maps.each do |m|
#   seed = apply_map(seed, m)
#   puts "Result: #{seed}"
#   puts ""
# end
