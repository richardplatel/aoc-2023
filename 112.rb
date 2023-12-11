def pinspect(*args)
  puts *args.map(&:inspect)
end


infile = "11.txt"
# infile = "11.txt"
row_empty = []
col_empty =[]
galaxies = []
$world = File.readlines(infile, chomp: true).each_with_index do | row, row_idx |
  row.split('').each_with_index do | value, col_idx |
    if value != "."
      galaxies << [row_idx, col_idx]
      row_empty[row_idx] = false
      col_empty[col_idx] = false
    else
      row_empty[row_idx] = true if row_empty[row_idx].nil?
      col_empty[col_idx] = true if col_empty[col_idx].nil?
    end
  end
end

# pinspect row_empty
# pinspect col_empty
# pinspect galaxies

FACTOR = 1000000 - 1
# expand space
expansion = 0
rx = row_empty.map do |e|
  expansion += FACTOR if e
  expansion
end
expansion = 0
cx = col_empty.map do |e|
  expansion += FACTOR if e
  expansion
end

galaxies = galaxies.map do |g|
  g[0] += rx[g[0]]
  g[1] += cx[g[1]]
  g
end

# pinspect galaxies

def distance(g1, g2)
  row_dist = (g1[0] - g2[0]).abs
  col_dist = (g1[1] - g2[1]).abs
  row_dist + col_dist
end

# puts distance(galaxies[4], galaxies.last)

# puts distance(galaxies[0], galaxies[0])

# puts distance(galaxies[0], galaxies[6])
# puts distance(galaxies[2], galaxies[5])
# puts distance(galaxies[7], galaxies[8])

# puts distance(galaxies[6], galaxies[0])
# puts distance(galaxies[5], galaxies[2])
# puts distance(galaxies[8], galaxies[7])


# puts("#{galaxies.combination(2).to_a}")
puts galaxies.combination(2).map {|pair| distance(*pair) }.sum
