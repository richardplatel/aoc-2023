

def pinspect(*args)
  puts *args.map(&:inspect)
end

class Pulse
  @@high_pulse_count = 0
  @@low_pulse_count = 0
  @@pulses = []

  attr :from
  attr :to
  attr :state

  class << self
    def hpc
      @@high_pulse_count
    end

    def lpc
      @@low_pulse_count
    end

    def pulses
      @@pulses
    end

    def next_pulse
      @@pulses.shift
    end

    def create_pulse(from, to, state)
      p = Pulse.new(from, to, state)
      if state == :high
        @@high_pulse_count += 1
      elsif state == :low
        @@low_pulse_count  += 1
      else
        raise "OH NO!"
      end
      @@pulses << p
      p
    end
  end

  def initialize(from, to, state)
    @from = from
    @to = to
    @state = state
  end

  def high?
    @state == :high
  end

  def low?
    @state == :low
  end

  def inspect
    "<P #{@from.inspect}--#{high? ? "H" : "L"}->#{@to.inspect}>"
  end
end

class Component
  @@components = {}

  attr :name
  attr :output_names
  attr_accessor :state

  class << self
    def components
      @@components
    end

    def create_component(name: nil, output_names: [])
      c = self.new(name, output_names)
      components[c.name] = c
      c
    end

    def do_one_pulse
      p = Pulse.next_pulse
      return false if p.nil?
      # pinspect p
      @@components[p.to].process_pulse(p)
      true
    end

    def conjunction_input_scan
      @@components.values.each do |c|
        c.output_names.each do |o|
          if @@components[o].is_a? Conjunction
            @@components[o].initialize_input(c.name)
          end
        end
      end
    end

    def ghost_component_scan
      @@components.values.each do |c|
        c.output_names.each do |o|
          if @@components[o].nil?
            puts ("G-G-G-G-Ghost component! #{o}")
            FlipFlop.create_component(name: o, output_names: [])
          end
        end
      end
    end
  end

  def initialize(name, output_names)
    @name = name
    @output_names = output_names.dup
  end

  def process_pulse(p)
    raise ("Daaaaaaang!")
  end

  def send_pulse_to_all_outputs(state)
    @output_names.each { | o | Pulse.create_pulse(@name, o, state) }
  end

end

class Button < Component
  def initialize(_name, _output_names)
    super(:button, [:broadcaster])
  end

  def push
    Pulse.create_pulse(:button, :broadcaster, :low)
  end
end

class Broadcast < Component
  def initialize(_name, output_names)
    super(:broadcaster, output_names)
  end

  def process_pulse(p)
    # no state, forward pulse to all outputs
    send_pulse_to_all_outputs(p.state)
  end
end

class FlipFlop < Component
  def initialize(name, output_names)
    super(name, output_names)
    @state = :off
  end

  def process_pulse(p)
    # if low, flip state and send pulse
    if p.low?
      if @state == :off
        @state = :on
        p_state = :high
      else
        @state = :off
        p_state = :low
      end
      send_pulse_to_all_outputs(p_state)
    end
  end
end

class Conjunction < Component

  def initialize(name, output_names)
    super(name, output_names)
    @state = {}
  end

  # need to scan all components and pre-populate this component's state with all low inputs
  def initialize_input(input_name)
    @state[input_name] = :low
  end

  def process_pulse(p)
    @state[p.from] = p.state
    output_state = @state.values.all?{|v| v == :high} ? :low : :high
    send_pulse_to_all_outputs(output_state)
  end
end

puts("HPC: #{Pulse.hpc}")
puts("LPC: #{Pulse.lpc}")
b = Button.create_component

# infile = '20_sample1.txt'
# infile = '20_sample2.txt'
infile = '20.txt'

File.readlines(infile, chomp: true).each do | c |
  (comp, output_list) = c.split(' -> ')
  outputs = output_list.split(', ').map(&:to_sym)
  if comp == "broadcaster"
    Broadcast.create_component(output_names: outputs)
  elsif
    comp[0] == '%'
    FlipFlop.create_component(name: comp[1..].to_sym, output_names: outputs)
  elsif
    comp[0] == '&'
    Conjunction.create_component(name: comp[1..].to_sym, output_names: outputs)
  else
    raise "BEEEEEEEANS!!!"
  end
end

Component.ghost_component_scan
Component.conjunction_input_scan
Component.components.each { |c| pinspect c}

(0...1000).each do
  b.push
  while(Component.do_one_pulse)
    true
  end
end

puts("HPC: #{Pulse.hpc}")
puts("LPC: #{Pulse.lpc}")
puts("HPC * LPC: #{Pulse.hpc * Pulse.lpc}")

# # b.push
# # puts("HPC: #{Pulse.hpc}")
# # puts("LPC: #{Pulse.lpc}")
# # Component.do_one_pulse
# # puts("HPC: #{Pulse.hpc}")
# # puts("LPC: #{Pulse.lpc}")
# # pinspect Pulse.pulses

# # Component.do_one_pulse
# # puts("HPC: #{Pulse.hpc}")
# # puts("LPC: #{Pulse.lpc}")
# # pinspect Pulse.pulses

# # # puts("HPC: #{Pulse.hpc}")
# # # puts("LPC: #{Pulse.lpc}")

# # # Pulse.create_pulse(:a, :b, :high)
# # # Pulse.create_pulse(:b, :a, :low)
# # # Pulse.create_pulse(:c, :d, :low)

# # # puts("HPC: #{Pulse.hpc}")
# # # puts("LPC: #{Pulse.lpc}")
# # # puts("#{Pulse.next_pulse.inspect}")
# # # puts("#{Pulse.next_pulse.inspect}")
# # # puts("#{Pulse.next_pulse.inspect}")
# # # puts("#{Pulse.next_pulse.inspect}")
