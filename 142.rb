def pinspect(*args)
  puts *args.map(&:inspect)
end

def invert_board(b)
  cols = b[0].length
  (0...cols).map do |c|
    b.map { |l| l[c]}.join('')
  end
end

def tilt_board_east(board)
  board.map do |row|
    row.split(/(#)/).map{ |section| section.split('').sort.join}.join
  end
end

def tilt_board_west(board)
  board.map do |row|
    row.split(/(#)/).map{ |section| section.split('').sort.reverse.join}.join
  end
end

def tilt_board_north(board)
  invert_board(tilt_board_west(invert_board(board)))
end

def tilt_board_south(board)
  invert_board(tilt_board_east(invert_board(board)))
end

def print_board(b)
  row_count = b.length
  b.each_with_index do |row, row_idx|
    i = row_count - row_idx
    puts("#{i.to_s.rjust(3,'0')}: #{row}")
  end
end

def score_board(b)
  row_count = b.length
  sum = 0
  b.each_with_index do |row, row_idx|
    i = row_count - row_idx
    s = i * (row.count('O'))
    sum += s
    puts("#{i.to_s.rjust(3,'0')}: #{row} #{s}")
  end
  sum
end

def detect_cycle(array)
  cycle_len = 1
  array_len = array.length
  while(cycle_len * 2 < array_len)
    if array[-cycle_len..-1] == array[(cycle_len * -2)..-(cycle_len+1)]
      return cycle_len
    end
    cycle_len +=1
  end
end

def board_at(boards, nth, cycle_length)
  # we know that board ends in  2 cycles of the given length
  nboards = boards.length
  pre_cycle_length = nboards - (2 * cycle_length)

  index_in_cycle = (nth - pre_cycle_length) % cycle_length - 1
  index_in_boards = pre_cycle_length + index_in_cycle

  return boards[index_in_boards]
end

# boards = %w[j u n k s y c l e s y c l e]

# # boards = %w[j u n k s y c l e s y c l e s y c l e s y c l e s y c l e]
# #             1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9

# pinspect detect_cycle(boards)
# pinspect board_at(boards, 23, 5)

infile = "14.txt"
board = File.readlines(infile, chomp: true).to_a

times = 1000_000_000
count = 1

boards = [board]
while count <= times do
  boards << tilt_board_east(tilt_board_south(tilt_board_west(tilt_board_north(boards.last))))
  cycle_length = detect_cycle(boards)
    if cycle_length
      puts score_board(board_at(boards[1..], times, cycle_length))  # starting at 1 because we have the initial board at boards[0]
      break
    end
  count += 1
end
