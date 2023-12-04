
MAXES = {
  "red" => 12,
  "green" => 13,
  "blue" => 14,
}

def allowed_group(group)
  (count, colour) = /(\d+)(\w+)/.match(group).captures
  return MAXES[colour] >= count.to_i
end

def possible(draw)
  puts draw.inspect
  draw.split(',').all? { |group| allowed_group(group) }
end

def do_game(line)
  (id, draws) = /Game(\d+):(.*)/.match(line).captures
  puts ("id: #{id.inspect} rest: #{draws.inspect}")
  draws.split(';').all?{|draw| possible(draw)} ? id.to_i : 0
end

sum = 0
File.readlines("21.txt", chomp: true).each do |line|
  line = line.delete(' ')
  sum += do_game(line)
end

puts ("------")
puts (sum)
