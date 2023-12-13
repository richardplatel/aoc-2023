def pinspect(*args)
  puts *args.map(&:inspect)
end

def scan_board(board)
  line_of_reflection = nil
  board.each_with_index do | line, idx |
    next if idx == 0
    if line_of_reflection.nil?
      if line == board[idx - 1]
        line_of_reflection = idx - 1
      end
    else
      pair = idx - (2 * (idx - line_of_reflection) - 1)
      break if pair < 0
      if board[pair] != line
        line_of_reflection = nil
      end
    end
  end
  return line_of_reflection
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


sum = 0
boards.each do |b|
  h = scan_board(b)
  v = scan_board(invert_board(b))
  if h
    sum += 100 * (h+1)
  end
  if v
    sum += (v+1)
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
