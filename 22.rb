

def do_game(line)
  (id, draws) = /Game(\d+):(.*)/.match(line).captures
  # puts draws.inspect
  ["red", "green", "blue"].map do |colour|
    draws.scan(/(\d+)#{colour}/).flatten.map(&:to_i).max
  end.reduce(:*)

end

sum = 0
File.readlines("21.txt", chomp: true).each do |line|
  line = line.delete(' ')
  sum += do_game(line)
end

puts ("------")
puts (sum)
