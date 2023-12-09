def pinspect(*args)
  puts *args.map(&:inspect)
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
current_node = "AAA"
steps = 0

while (current_node != "ZZZ")
  direction = path[steps % path_length]
  puts "#{current_node} --> #{marp[current_node]}, #{direction}"
  current_node = marp[current_node][direction]
  steps += 1
end

puts "Steps: #{steps}"
