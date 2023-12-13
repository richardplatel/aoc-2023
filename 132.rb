def pinspect(*args)
  puts *args.map(&:inspect)
end

def equal_with_smudge (l1, l2)
  l1.split('').zip(l2.split('')).select{|pair| pair[0] != pair[1]}.count == 1
end

# (smudged, equal)
def lines_equal(l1, l2, smudgeable)
  if l1 == l2
    [false, true]
  elsif (smudgeable && equal_with_smudge(l1, l2))
    [true, true]
  else
    [false, false]
  end
end

def scan_board(board, skip_to: 1)
  line_of_reflection = nil
  smudged = false
  board.each_with_index do | line, idx |
    next if idx < skip_to
    # puts ("Hey: #{idx}")
    if line_of_reflection.nil?
      (s, e) = lines_equal(line, board[idx - 1], true)
      # puts ("s: #{s} e: #{e}")
      if e
        line_of_reflection = idx - 1
        smudged = s
        # puts ("FIRST #{idx} pair #{idx - 1} smudged? #{smudged ? "S" : "ns"}")
      end
    else
      pair = idx - (2 * (idx - line_of_reflection) - 1)
      # puts ("#{idx} pair #{pair} smudged? #{smudged ? "S" : "ns"}")
      if pair < 0
        if smudged
          break
        else
          line_of_reflection = nil
          smudged = false
        end
      else
        (s, e) = lines_equal(board[pair], line, !smudged)
        # puts ("x s: #{s} e: #{e} #{smudged ? "S" : "ns"}")
        if e
          if !smudged
            smudged = s
          end
          # puts "hello #{smudged ? "S" : "ns"}"

        else
          line_of_reflection = nil
          smudged = false
        end
      end
    end
    # puts("#{idx}: #{line} #{line_of_reflection || 'X'} #{smudged ? "S" : "ns"}")
  end

  # smudged ? line_of_reflection : nil
  if smudged
    # board.each_with_index { |l, idx| puts ("#{idx} : #{idx == line_of_reflection ? '>' : " "} #{l} #{idx == line_of_reflection ? '<' : " "}")}
    return line_of_reflection
  else
    if line_of_reflection
      # puts ("No smudged match retrying, lor: #{line_of_reflection}")
      return scan_board(board,skip_to: line_of_reflection + 2)
    else
      # puts ("No smudged match")
      return nil
    end
  end


end

def invert_board(b)
  cols = b[0].length
  (0...cols).map do |c|
    b.map { |l| l[c]}.join('')
  end
end

infile = "131.txt"
boards = []
board = []
File.readlines(infile, chomp: true).each_with_index do | row, row_idx |
  # puts ("#{row}")
  if row != ""
    board << row
  else
    # puts ("woo")
    boards << board
    board = []
  end
end
boards << board


# pinspect scan_board(boards[0])

sum = 0
boards.each do |b|
  h = scan_board(b)
  # puts ("\n---\n")
  v = scan_board(invert_board(b))
  # puts ("\n------------\n\n")
  if h
    sum += 100 * (h+1)
  end
  if v
    sum += (v+1)
  end
  if !(h || v)
    h2 = scan_board(b.reverse)
    v2 = scan_board(invert_board(b).reverse)
    if (h2 || v2)
      puts ("HA HA!")
    else
      puts ("OH NO")
      b.each_with_index { |l, idx| puts ("#{idx.to_s.rjust(2,'0')} : #{l}")}
      # scan_board(b)
      # puts ('------')
      # invert_board(b).each_with_index { |l, idx| puts ("#{idx.to_s.rjust(2,'0')} : #{l}")}
      # puts ('------')
      # scan_board(invert_board(b))
      # break
    end
  end
end
puts ("-------")
puts ("#{sum}")

# boards.each do |b|
#   b.each_with_index { |l, idx| puts ("#{idx} : #{l}")}
#   puts ("")
#   inv = invert_board(b)
#   inv.each_with_index { |l, idx| puts ("#{idx} : #{l}")}
#   puts ("---------")
# end
