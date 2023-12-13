def pinspect(*args)
  puts *args.map(&:inspect)
end


infile = "12.txt"
$world = File.readlines(infile, chomp: true).map do | row |
  (field, check) = row.split(" ")
  [field, check.split(',').map(&:to_i)]
end

def combize(combos, idx)

  if idx >= combos[0].length
    return combos
  end

  this = combos[0][idx]

  if this == '?'
    add_ons = ['#', '.']
    combos = combos.flat_map do |c|
      [
        c[0...idx] + '#' + c[idx+1..],
        c[0...idx] + '.' + c[idx+1..],
      ]
    end
  end
  return combize(combos, idx+1)
end

def valid(combo, check)
  # start of string, dots ( [n hashes followed by a not-hash], dots), end of string
  dots = '\.*'
  r =
    '^' + dots +
    check.map { |c| "[#]{#{c}}(?:[^#]|\\z)" + dots }.join('') +
    '$'
  re = Regexp.new r
  combo.match?(re)
end

# pinspect combize([$world[0][0]], 0)

# $world.map do |row|
#   comboize(row[0], 0).fil

sum = 0
$world.each do | row |
  arrangements = combize([row[0]], 0).select { |c| valid(c, row[1])}
  puts "#{row[0]} -- #{row[1]}: #{arrangements.count}"
  arrangements.each { |a| puts a}
  sum += arrangements.count
  puts "--"
end

puts ("-----------")
puts sum


# combo = ".###.##.#.##"
# check = [3, 2, 1]

# pinspect valid(combo, check)
