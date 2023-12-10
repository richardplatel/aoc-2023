def pinspect(*args)
  puts *args.map(&:inspect)
end


def next_line(nums)
  prev = nums[0]
  nums[1..].map do |x|
    diff = x - prev
    prev = x
    diff
  end
end

def pyramid(nums)
  out = [nums]
  while (out.last.uniq.size > 1)
    # pinspect(out)
    out << next_line(out.last)
  end
  out
end

def pyrasum (nums_list)
  nums_list.map(&:last).reduce(:+)
end

def pyraboop (nums_list)
  odds = []
  evens = []
  nums_list.map(&:first).each_with_index do | v, i |
    if i % 2 == 0
      evens << v
    else
      odds << v
    end
  end
  evens.sum - odds.sum
end


infile = '9.txt'

input = File.readlines(infile, chomp: true).map do | l |
  l.scan(/-?\d+/).map(&:to_i)
end


pyramids = input.map { |l| pyramid(l)}
# pinspect pyramids.map(&method(:pyrasum))
# pinspect pyramids.map(&method(:pyrasum)).sum


pyramids.each { |p| pinspect p}
pinspect pyramids.map(&method(:pyraboop))
pinspect pyramids.map(&method(:pyraboop)).sum
