def pinspect(*args)
  puts *args.map(&:inspect)
end

# make hands sortable ascii-betically
TRANSLATION = {
  'A' => 'E',
  'K' => 'D',
  'Q' => 'C',
  'J' => 'B',
  'T' => 'A'
}.tap { |h| h.default_proc = ->(h,k) { k } }

def strength(hand)
  hs = hand.split('').sort.join
  return 1 if hs.match(/(.)\1{4}/)
  return 2 if hs.match(/(.)\1{3}/)
  return 3 if hs.match(/(.)\1\1(.)\2/) || hs.match(/(.)\1(.)\2\2/)
  return 4 if hs.match(/(.)\1\1/)
  return 5 if hs.match(/(.)\1.?(.)\2/)
  return 6 if hs.match(/(.)\1/)
  return 7
end

def hand_compare(a,b)
  # puts("#{a} <=> #{b}")
  return a[0] <=> b[0] if a[2] == b[2] # compare ascii-betically if strengths are equal
  return b[2] <=> a[2]
end

hands = File.readlines("7.txt", chomp: true).map do |line|
  out = line.gsub(Regexp.union(TRANSLATION.keys), TRANSLATION).split(' ')
  out[1] = out[1].to_i
  out[2] = strength(out[0])
  out  #[translated_hand, bid, hand_strength]
end



# part 1
# hands.sort {|a,b| hand_compare(a,b)}.each {|x| puts x.join(', ')}
puts hands.sort {|a,b| hand_compare(a,b)}.each_with_index.map { |h, i| h[1] * (i+1) }.sum
