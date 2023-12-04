
NUMS = '0123456789'.split('')
def first_num(l)
  l.split('').each do |c|
    return c if NUMS.include?(c)
  end
end

def last_num(l)
  return first_num(l.reverse)
end

sum = 0
File.readlines("1.txt", chomp: true).each do |line|
  calibration = "#{first_num(line)}#{last_num(line)}"
  puts calibration.inspect
  sum += calibration.to_i
end

puts("-----")
puts ("#{sum}")
