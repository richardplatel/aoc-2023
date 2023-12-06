def pinspect(*args)
  puts *args.map(&:inspect)
end

def min_hold_for_distance(distance, duration)
  ((duration - Math.sqrt(duration**2 - 4 * distance))/2).floor + 1
end

def max_hold_for_distance(distance, duration)
  ((duration + Math.sqrt(duration**2 - 4 * distance))/2).ceil - 1
end


(times, distances) = File.readlines("6.txt", chomp: true).map do |line|
  line.scan(/\d+/).map(&:to_i)
end

input = times.zip(distances)
pinspect input
TIME = 0
DISTANCE_TO_BEAT = 1


ways = input.map do |race|
  # puts(max_hold_for_distance(race[DISTANCE_TO_BEAT], race[TIME]))
  # puts(min_hold_for_distance(race[DISTANCE_TO_BEAT], race[TIME]))

  max_hold_for_distance(race[DISTANCE_TO_BEAT], race[TIME]) - min_hold_for_distance(race[DISTANCE_TO_BEAT], race[TIME]) + 1
end

pinspect ways
puts ways.reduce(:*)
