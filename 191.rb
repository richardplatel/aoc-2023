def pinspect(*args)
  puts *args.map(&:inspect)
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

  # nil or a step
  def apply(part)
    @goto if @operation.nil? or @operation.call(part[@operand])
  end

  def initialize(instruction_str)
    bits = instruction_str.split(':')
    @goto = bits.pop.to_sym
    op = bits.shift
    if op
      op_bits = op.split(/([<>])/)
      @operand = op_bits[0].to_sym
      @operation = make_operation(op_bits[1], op_bits[2])
    end
  end

  def make_operation(operator, amt)
    if operator == '<'
      @oper_inspect = "<#{amt}"
      ->(o){o < amt.to_i}
    elsif operator == '>'
      @oper_inspect = "<#{amt}"
      ->(o){o > amt.to_i}
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

parts = parts_input.map do |p|
  part_from_str(p)
end

# pinspect workflows
# pinspect parts

accepted_parts = parts.select do |p|
  w = :in
  print ("#{w.inspect}")
  until (terminal?(w))
    w = do_a_workflow(workflows[w], p)
    print (" -> #{w.inspect}")
  end
  puts ("")
  w == :A
end

pinspect accepted_parts
result = accepted_parts.map { |p| p.values.sum }.sum
puts "Result: #{result}"
