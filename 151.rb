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

infile = "15.txt"
pinspect input(infile).map{|chunk| hashem(chunk)}.sum
