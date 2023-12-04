def pinspect(*args)
  puts *args.map(&:inspect)
end

def count_to_score(count)
  return 0 if count == 0
  return 2**(count-1)
end

def count_game(winners, have)
  winners.flat_map {|w| have.select{|h| h == w }}.length
end

def score_game(winners, have)
  count_to_score(count_game(winners, have))
end

# Part 1
sum = 0
File.readlines("41.txt", chomp: true).each do |line|
  (game, winners, have) = line.split(/[:|]/).map { |game| game.scan(/\d\d*/)}
  sum += score_game(winners, have)
end
puts(sum)


# Part 2
# [ [points, instances] ]
cards = File.readlines("41.txt", chomp: true).map do |line|
  (game, winners, have) = line.split(/[:|]/).map { |game| game.scan(/\d\d*/)}
  [count_game(winners, have), 1]
end

max_game = cards.length - 1

sum = (0..max_game).sum do |i|
  (points, instances) = cards[i]
  if points
    (i+1..i+points).each do |i2|
      cards[i2][1] += instances
    end
  end
  instances
end

puts sum
