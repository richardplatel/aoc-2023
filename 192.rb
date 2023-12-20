def pinspect(*args)
  puts *args.map(&:inspect)
end


class PartRange
  MIN = 0
  MAX = 1
  attr_accessor :ranges

  def initialize(pr_source=nil)
    if pr_source
      @ranges = {}
      pr_source.ranges.each { |k, v| @ranges[k] = v.dup}
    else
      @ranges = {
      x: [1, 4000],
      m: [1, 4000],
      a: [1, 4000],
      s: [1, 4000],
    }
  end

  end

  def size
    @ranges.values.map do |r|
      r[MAX] - r[MIN] + 1
    end.inject(:*)
  end

  def inspect
    "<PR " + @ranges.map {|k,v| "#{k}:(#{v[0]},#{v[1]}) "}.join + ">"
  end

  class << self
    def partition(pr, what, about)
      # partition this range in to two ranges, 'whats' less than about and 'whats' >= about
      # one range might be empty
      if pr.ranges[what][MAX] < about
        [PartRange.new(pr), nil]
      elsif about <= pr.ranges[what][MIN]
        [nil, PartRange.new(pr)]
      else
        left = PartRange.new(pr)
        left.ranges[what][MAX] = about - 1

        right = PartRange.new(pr)
        right.ranges[what][MIN] = about
        [left, right]
      end
    end
  end
end

# my_lambda_with_args = -> (v) { puts "hello "+v }
# instruction
#  - operand
#  - test
#  - result / goto
class Instruction
  attr :operand
  attr :operation
  attr :goto
  attr :oper_inspect

  # # nil or a step
  # def apply(part)
  #   @goto if @operation.nil? or @operation.call(part[@operand])
  # end

  def apply_to_range(part_range)
    # return 1 or 2 of
    #   [nil | workflow], range
    # nil -> send range to next step in this workflow
    # workflow -> send range to workflow

    return [[@goto, part_range]] if @operation.nil?

    @operation.call(part_range)
  end

  def initialize(instruction_str)
    bits = instruction_str.split(':')
    @goto = bits.pop.to_sym
    op = bits.shift
    if op
      op_bits = op.split(/([<>])/)
      @operand = op_bits[0].to_sym
      @operation = make_operation(op_bits[1], op_bits[2].to_i)
    end
  end

  def make_operation(operator, amt)
    if operator == '<'
      @oper_inspect = "<#{amt}"
      ->(r){
        (left, right) = PartRange.partition(r, @operand, amt)
        [
          left ? [@goto, left] : nil,
          right ? [nil, right] : nil,
        ].compact
      }
    elsif operator == '>'
      @oper_inspect = "<#{amt}"
      ->(r){
        (right, left) = PartRange.partition(r, @operand, amt+1)
        [[@goto, left], [nil, right]]
      }
    else
      raise "UNKNOWN OPERATOR #{operator.inspect}"
    end
  end

  def inspect
    "<I\"#{@operand.inspect}#{oper_inspect}\"->#{@goto.inspect}>"
  end
end

def part_from_str(pstr)
  pstr.scan(/[xmas]=\d+/).map do |p|
    (a,v) = p.split('=')
    [a.to_sym, v.to_i]
  end.to_h
end

def do_a_workflow(w, p)
  # first instruction that returns a workflow.  Last instruction garunteed to return a workflow
  w.lazy.map{ |i| i.apply(p) }.reject(&:nil?).first
end

def terminal?(w)
  [:R,:A].include?(w)
end




infile = '19.txt'
# infile = '19_sample.txt'
# infile = '19_dbg.txt'

input = File.readlines(infile, chomp: true).to_a
split = input.index('')
wf_input = input[0...split]
parts_input = input[split+1..]


# workflows {
#  name => [instructions]
# }
workflows = wf_input.map do |w|
  bits = w.split(/[{}]/)
  name = bits[0].to_sym
  [
    name ,
    bits[1].split(',').map do | i |
      Instruction.new(i)
    end
  ]
end.to_h

accepted_ranges = []
rejected_ranges = []

in_progress = [[:in, PartRange.new]]
steps = 0
until in_progress.empty?
  puts("Accepted #{accepted_ranges.inspect}")
  puts("Rejected #{rejected_ranges.inspect}")
  puts("In progress: #{in_progress}")
  ip = in_progress.pop
  wf = workflows[ip[0]]
  r = ip[1]
  # pinspect wf
  wf.each do | i |
    puts("  #{i.inspect}")
    i.apply_to_range(r).each do | ipp |
      puts("   ipp: #{ipp.inspect}")
      if ipp[0].nil?
        r = ipp[1]
      elsif terminal?(ipp[0])
        if ipp[0] == :R
          puts ("Rejecting: #{r.inspect}")
          rejected_ranges << ipp[1]
        else
          puts ("Accepting: #{r.inspect}")
          accepted_ranges << ipp[1]
        end
      else
        in_progress << ipp
      end
    end
  end
  steps += 1
  puts ("")
  # break if steps == 4
end


puts ("---")
puts("Accepted #{accepted_ranges.inspect}")
puts("Rejected #{rejected_ranges.inspect}")

ar = accepted_ranges.map{ |r| r.size }.sum
rr = rejected_ranges.map{ |r| r.size }.sum

puts("Found: #{ar + rr}")
puts("Should:#{PartRange.new.size}")
puts("Accepted combos: #{ar}")

# parts = parts_input.map do |p|
#   part_from_str(p)
# end

# pinspect workflows
# pinspect parts

# accepted_parts = parts.select do |p|
#   w = :in
#   print ("#{w.inspect}")
#   until (terminal?(w))
#     w = do_a_workflow(workflows[w], p)
#     print (" -> #{w.inspect}")
#   end
#   puts ("")
#   w == :A
# end

# pinspect accepted_parts
# result = accepted_parts.map { |p| p.values.sum }.sum
# puts "Result: #{result}"
