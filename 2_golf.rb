
TRANSLATION = {
  "oneight" => "18",
  "twone" => "21",
  "threeight" => "38",
  "fiveight" => "58",
  "sevenine" => "79",
  "eightwo" => "82",
  "nineight" => "98",
  "one" => "1",
  "two" => "2",
  "three" => "3",
  "four" => "4",
  "five" => "5",
  "six" => "6",
  "seven" => "7",
  "eight" => "8",
  "nine" => "9",
}

def numify(l)
  TRANSLATION.each do |k,v|
    l = l.gsub(k,v)
  end
  l
end

puts "#{File.readlines("2.txt", chomp: true).map do |line|
  numify(line).scan(/\d/).values_at(0,-1).join.to_i
end.sum}"
