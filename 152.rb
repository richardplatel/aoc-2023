def pinspect(*args)
  puts *args.map(&:inspect)
end

def input(in_file)
  Enumerator.new do |y|
    bit = ''
    File.new(in_file).each_char.select{ |c| c!="\n" }.each do |c|
      if c == ','
        y << bit
        bit = ''
      else
        bit << c
      end
    end
    y << bit
  end
end

def hashem(s)
  sum = 0
  s.split('').each do |c|
    sum = ((sum + c.ord) * 17) % 256
  end
  sum
end

# [ operation, box, label, focal_length]
def parse_instruction(i)
  bits = i.split(/([-=])/)
  [bits[1], hashem(bits[0]), bits[0], bits[2]]
end

REMOVE='-'
ADD='='

infile = "15.txt"
boxes = (0..255).map{ {} }

input(infile).each do |i|
  (op, box, label, focal_length) = parse_instruction(i)
  if op == REMOVE
    boxes[box].delete(label)
  else
    boxes[box][label] = focal_length
  end
end

sum = 0
pinspect boxes
boxes.each_with_index do |b, bi|
  b.values.each_with_index do |f, fi|
    sum += (bi + 1) * (fi + 1) * f.to_i
  end
end
puts sum
# pinspect boxes
