def pinspect(*args)
  puts *args.map(&:inspect)
end

RSTART=0
REND=1
ROFF=2

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

seed_ranges = maps.shift[0]
seeds = []
#[seed_start, range] -> [seed_start, seed_end]
seed_ranges.each_slice(2) do | start, range |
  seeds << [start, start + range - 1]
end

# [destination_start, source_start, range] -> [source_min, source_max, offset]
maps = maps.map do |m|
  m.map { |r| [r[1], r[1] + r[2] - 1, r[0] - r[1]] }
end

# [seed range], [map range]  -> [seed range before], [seed range overlap], [seed range after]
def chormp(seed_range, map_range)
  if seed_range[REND] < map_range[RSTART]
    return seed_range, nil, nil
  end

  if map_range[REND] < seed_range[RSTART]
    return nil, nil, seed_range
  end

  if map_range[RSTART] > seed_range[RSTART]
    # there is a before part and an overlap and possibly an after part
    if map_range[REND] < seed_range[REND]
      # there is an after part
      return [seed_range[RSTART], map_range[RSTART] - 1], [map_range[RSTART], map_range[REND]], [map_range[REND] + 1, seed_range[REND]]
    else
      # there is no after_part
      return [seed_range[RSTART], map_range[RSTART] - 1], [map_range[RSTART], seed_range[REND]], nil
    end
  else
    # there is no before part, there is an overlap and possibly an after part
    if map_range[REND] < seed_range[REND]
      # there is an after part
      return nil, [seed_range[RSTART], map_range[REND]], [map_range[REND] + 1, seed_range[REND]]
    else
      # there is no after_part
      return nil, [seed_range[RSTART], seed_range[REND]], nil
    end
  end
end


puts ("maps:")
pinspect maps
puts ("seeds:")
pinspect seeds

puts ("---")

maps.each do | m |
  seeds_next_map = []
  puts ("map seeds: #{seeds.inspect}")
  m.each do | r |
    puts ("range seeds: #{seeds.inspect}")
    seeds_next_range = []
    puts ("range: #{r.inspect}")
    seeds.each do | s |
      puts ("  seed: #{s.inspect}")
      b, o, a = chormp(s, r)
      if o
        o[RSTART] += r[ROFF]
        o[REND] += r[ROFF]
        seeds_next_map << o
      end
      seeds_next_range << b if b
      seeds_next_range << a if a
      puts ("    b: #{b.inspect}, o: #{o.inspect}, a: #{a.inspect}")
    end
    seeds = seeds_next_range
    puts ("---")
  end
  seeds = seeds.concat(seeds_next_map)
  puts ("-------------")
end

pinspect seeds
puts seeds.map {|s| s[0]}.min
