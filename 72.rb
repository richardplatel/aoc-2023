def pinspect(*args)
  puts *args.map(&:inspect)
end

# make hands sortable ascii-betically
TRANSLATION = {
  'A' => 'E',
  'K' => 'D',
  'Q' => 'C',
  'J' => '*',
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

SUBBERS = (1..4).flat_map do |t|
  %w(2 3 4 5 6 7 8 9 A C D E).map do |c|
    c * t
  end
end.reverse


def dejokerize(hand)
  hs = hand.split('').sort.join
  SUBBERS.each do |s|
    if hs.include? s
      return hand.gsub(/\*/, s[0])
    end
  end
  hand
end

def hand_compare(a,b)
  # puts("#{a} <=> #{b}")
  return a[0] <=> b[0] if a[2] == b[2] # compare ascii-betically if strengths are equal
  return b[2] <=> a[2]
end

hands = File.readlines("7.txt", chomp: true).map do |line|
  # out = line.gsub(Regexp.union(TRANSLATION.keys), TRANSLATION).split(' ')
  out = line.split(' ')
  inh = out[0]
  out[0] = out[0].gsub(Regexp.union(TRANSLATION.keys), TRANSLATION)
  out[1] = out[1].to_i
  dj = dejokerize(out[0])
  out[2] = strength(dj)
  out[3] = dj
  out  #[translated, bid, strength, dejokerized]
end



# part 2
# hands.each {|x| puts x.join(', ')}
# hands.sort {|a,b| hand_compare(a,b)}.each {|x| puts x.join(', ')}
puts hands.sort {|a,b| hand_compare(a,b)}.each_with_index.map { |h, i| h[1] * (i+1) }.sum
# 246285222
