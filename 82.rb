require "Prime"

def pinspect(*args)
  puts *args.map(&:inspect)
end

def all_that_end_with(inp, last)
  inp.select { |n| n.end_with?(last)}
end

def all_end_with?(inp, last)
  inp.all? { |n| n.end_with?(last)}
end

def is_factor?(a,b)
  (b % a) == 0
end

def prime_factors(a)
  factors = []
  Prime.each do | p |
    if p > a
      return factors
    end
    if is_factor?(p, a)
      a = a / p
      factors << p
    end
  end
end

infile = '8.txt'

input = File.readlines(infile, chomp: true).to_a

path = input.shift.split('').map { |d| d == 'L' ? 0 : 1}
input.shift

marp = input.map do |line|
  bits = line.scan(/\w+/)
  [bits[0], [bits[1], bits[2]]]
end.to_h

pinspect path
pinspect marp
puts ("")


path_length = path.length
start_nodes = all_that_end_with(marp.keys.select, "A")
steps = 0

pinspect start_nodes


cycles = start_nodes.map do | s |
  current_node = s
  puts ("cycling #{current_node}")
  steps = 0
  while (!current_node.end_with?('Z'))
    direction = path[steps % path_length]
    current_node = marp[current_node][direction]
    steps += 1
  end
  [s, steps]
end

pinspect cycles

puts cycles.map { |c| Prime.prime?(c[1])}

nums = cycles.map { |c| c[1]}
pinspect nums

cool_guys = nums.map { |n| prime_factors(n)}

pinspect cool_guys

# I finished this by hand
#
# should have realized that number.lcm() exists.


