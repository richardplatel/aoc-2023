def pinspect(*args)
  puts *args.map(&:inspect)
end


infile = "12_sample.txt"
$world = File.readlines(infile, chomp: true).map do | row |
  (field, check) = row.split(" ")
  [field + '?' + field + '?' + field + '?'+ field + '?' + field, check.split(',').map(&:to_i) * 5]
end

def so_far(combo)
  combo.split('?')[0].split('.').map(&:length).select(&:positive?)
end

def partial_valid(combo, check)
  sf = so_far(combo)
  # puts ("sf: #{sf}, check: #{check}")
  (sf.length <= check.length) &&
    ((sf.length <= 1) ||
    (sf[...-1] == check[...sf.length-1]))
end

def combize(combos, idx, check)
  # puts ("#{combos}, #{idx}")
  if idx >= combos[0].length
    return combos
  end

  this = combos[0][idx]

  if this == '?'
    combos = combos.flat_map do |c|
      h = c[0...idx] + '#' + c[idx+1..]
      d = c[0...idx] + '.' + c[idx+1..]

      [
        partial_valid(h, check) ? h : nil,
        partial_valid(d, check) ? d : nil
      ].compact
    end
  end
  return combize(combos, idx+1, check)
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


def builder(field, match)
  length = match.length
  puts ("field: #{field}, match: #{match}, length: #{length}")
  guys = field.map { |l| "#" * l + '.'}
  guys[-1] = guys[-1].chop
  dot_count = length - guys.map(&:length).sum
  dot_spots = guys.length + 1
  max_dots = match.split(/[.#]/).map(&:length).max

  # most dots = longest run of ??s in match


  puts ("guys: #{guys}, dot_count: #{dot_count}, dot_spots: #{dot_spots}, max_dots: #{max_dots}")
end


# $world.map do |row|
#   comboize(row[0], 0).fil

# sum = 0
# $world.each_with_index do | row, index |
#   arrangements = combize([row[0]], 0, row[1]).select { |c| valid(c, row[1])}
#   puts "#{index}: #{row[0]} -- #{row[1]}: #{arrangements.count}"
#   # arrangements.each { |a| puts a}
#   sum += arrangements.count
#   puts "--"
# end

# puts ("-----------")
# puts sum


# combo = ".###.##.#.##"
# check = [3, 2, 1]

# pinspect valid(combo, check)

# pinspect combize([$world[2][0]], 0, $world[2][1]).select { |c| valid(c, $world[2][1])}

puts ("")
builder($world[4][1],$world[4][0])
puts ("")


def foo(length,total)
  # [*0..t].repeated_permutation(n){|a|a.sum==t}
  # [*0..5].repeated_permutation(3).select{ |p| p.sum == 5 }
  return [ [total] ] if length == 1
  # puts "#{length}, #{total}"
  (0..total).flat_map do |n|
    foo(length - 1, total - n).map { |f| [n] + f}
  end
end

def bar(total, max, max_len)
  return [ [total] ] if total <= 1

  [[total]] + bar(total - 1, max, max_len).map { |b| [1] + b}
end


def bark(length, total, max)
  (0..max).to_a.combination(length).select{ |p| p.sum == total}
end

def beef(length, total, max)
  return [ [total] ] if length == 1

  (0..[max,total].min).flat_map do |n|
    beef(length - 1, total - n, max).map { |b| b + [n]}
  end
end

# beef(10, 10, 5).each { |c| pinspect c}
#beef(16, 20, 10)
