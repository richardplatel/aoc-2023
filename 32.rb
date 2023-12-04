
def pinspect(*args)
  puts *args.map(&:inspect)
end


# [part_no, start_idx, end_idx]

raw_field = []
File.readlines("31.txt", chomp: true).each do |line|
  raw_field.append(line)
end

# [part_no, [columns occupied]
all_parts = raw_field.map do |row|
  res = []
  row.scan(/\d+/) do |part_no|
    res << [part_no, (Regexp.last_match.offset(0)[0]...Regexp.last_match.offset(0)[1]).to_a]
  end
  res
end

def parts_around(all_parts, ri, ci)
  all_parts[ri-1..ri+1].flat_map do |row|
    parts =row.find_all do | part |
      part[1].intersection((ci-1..ci+1).to_a).length > 0  # part columns occupied intersection with our search columns
    end
    parts.map(&:first)
  end
end

sum = 0
raw_field.each_with_index do | row, row_index |
  # puts row
  row.scan('*') do
    # puts ("Got one at #{row_index},#{Regexp.last_match.offset(0)[0]}")
    parts = parts_around(all_parts, row_index, Regexp.last_match.offset(0)[0])
    if (parts.length == 2)
      sum += parts.map(&:to_i).reduce(:*)
    end
  end
end
puts (sum)
