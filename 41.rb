def pinspect(*args)
  puts *args.map(&:inspect)
end

def count_to_score(count)
  return 0 if count == 0
  return 2**(count-1)
end

def score_game(winners, have)
  count_to_score(winners.flat_map {|w| have.select{|h| h == w }}.length)
end

sum = 0
File.readlines("41.txt", chomp: true).each do |line|
  (game, winners, have) = line.split(/[:|]/).map { |game| game.scan(/\d\d*/)}
  sum += score_game(winners, have)
end

puts(sum)
