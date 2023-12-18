def pinspect(*args)
  puts *args.map(&:inspect)
end

def complete(field)
  field.index('?').nil?
end

def valid(field, pattern)
  field.scan(/\#+/).map(&:length) == pattern
end

def partial_valid(field, pattern)
  # too many hashes
  return false if field.count('#') > pattern.sum

  # too many dots
  max_dots = field.length - pattern.sum
  return false if field.count('.') > max_dots

  # doesn't match pattern
  q = field.index('?')
  so_far = field[...q]
  blobs_so_far =  so_far.scan(/\#+/)
  pattern_so_far = blobs_so_far.map(&:length)

  # if so_far ends with '#', final <= pattern[last_bit] else final == pattern[last_bit]
  if so_far.end_with?('#')
    final = pattern_so_far.pop
    return false if final > blobs_so_far.last.length
  end

  pattern_so_far == pattern[...pattern_so_far.length]
end

def do_field(field, pattern)
  hashkey = "#{field}#{pattern}"
  unless $cache[hashkey]
    $cache[hashkey] = really_do_field(field, pattern)
  end
  return $cache[hashkey]
end


def really_do_field(field, pattern)
  if complete(field)
    return valid(field, pattern) ? 1 : 0
  end

  # concrete part valid?
  return 0 if !partial_valid(field, pattern)

  q = field.index('?')
  if q > 0 && field[q-1] == '.'
    
    so_far = field[...q]
    to_go = field[q..]
    pattern_so_far = so_far.scan(/\#+/).map(&:length)
    pattern_to_go = pattern[pattern_so_far.length..]
    # puts("so_far #{so_far}, pattern_so_far: #{pattern_so_far}")
    # puts("to_go #{to_go}, pattern_to_go: #{pattern_to_go}")
    return do_field(to_go, pattern_to_go)
  else
    avec_hash = field.dup
    avec_hash[q] = '#'
    avec_dot = field.dup
    avec_dot[q] = '.'
    return do_field(avec_hash, pattern) + do_field(avec_dot, pattern)
  end
end



# pinspect do_field('.??..??...?##.', [1,1,3])

infile = "12.txt"
$world = File.readlines(infile, chomp: true).map do | row |
  (field, check) = row.split(" ")
  [field + '?' + field + '?' + field + '?'+ field + '?' + field, check.split(',').map(&:to_i) * 5]
end


sum = 0
$world.each do |s|
  $cache = {}
  pinspect s
  arr = do_field(*s)
  puts arr
  sum += arr
end
puts ("----")
puts (sum)
