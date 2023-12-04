
NUMS = '0123456789'.split('')
TRANSLATION = {
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

NOITALSNART = TRANSLATION.map { |k,v| [k.reverse, v] }.to_h



def numify(l, xlation)
  outstr = ""
  idx = 0
  while idx < l.length do
    xlation.each do |k, v|
      if l[idx..].start_with?(k)
        outstr += v
        idx += k.length
        outstr += l[idx..]
        return outstr
      end
    end
    outstr += l[idx]
    idx += 1
  end
  return outstr
end

def numify_forward(l)
  numify(l, TRANSLATION)
end

def numify_backward(l)
  numify(l.reverse, NOITALSNART).reverse
end


def first_num(l)
  l.split('').each do |c|
    return c if NUMS.include?(c)
  end
end

def last_num(l)
  return first_num(l.reverse)
end

sum = 0
File.readlines("2.txt", chomp: true).each do |line|
  fwd = numify_forward(line)
  bkw = numify_backward(line)
  calibration = "#{first_num(fwd)}#{last_num(bkw)}"
  puts calibration.inspect
  sum += calibration.to_i
end

puts("-----")
puts ("#{sum}")
