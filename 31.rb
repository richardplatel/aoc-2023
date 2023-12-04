
def is_digit?(c)
  !!(c =~ /[0-9]/)
end

def is_symbol?(c)
  !is_digit?(c) && c != '.'
end

def search_box(row, column)
  [-1, 0, 1].flat_map{ |y| [-1, 0, 1].map { |x| [row + x, column + y]} }.filter { |c| c[0] >= 0 && c[1] >= 0 && c[0] <= MAX_ROW && c[1] <=MAX_COL}
end

def is_part_no(field, row, column)
  search_box(row, column).any?{|c| is_symbol?(field[c[0]][c[1]])}
end

field = []
File.readlines("31.txt", chomp: true).each do |line|
  field.append(line.split(''))
end

MAX_ROW = field.length - 1
MAX_COL = field[0].length - 1

# puts ("#{MAX_ROW}, #{MAX_COL}")


number = ""
in_number = false
this_number_is_part_number = false

sum = 0

field.each_with_index do | row, row_idx |
  row.each_with_index do | value, column_idx |
    # puts("(#{row_idx}, #{column_idx}) => #{value}")
    if (is_digit?(value))
        if (!in_number)
          in_number = true
        end
        if (!this_number_is_part_number && is_part_no(field, row_idx, column_idx))
          this_number_is_part_number = true
        end
        number += value
    else
      if in_number
        if this_number_is_part_number
          sum += number.to_i
        end
        in_number = false
        number = ""
        this_number_is_part_number = false
      end
    end
  end
  if in_number
    if this_number_is_part_number
      sum += number.to_i
    end
    in_number = false
    number = ""
    this_number_is_part_number = false
  end
end

puts ("-------")
puts (sum)
