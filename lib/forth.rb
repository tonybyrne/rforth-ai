class Forth
  class ForthError < StandardError; end
  class StackUnderflow < ForthError; end
  class UnknownWord < ForthError; end

  attr_reader :stack, :dictionary

  def initialize
    @stack = []
    @dictionary = {}
    @variables = {}
    @loop_stack = []
    setup_builtins
  end

  def execute(input)
    tokens = input.is_a?(Array) ? input : input.downcase.split
    while !tokens.empty?
      token = tokens.shift
      if token == ":"
        define_word(tokens)
      elsif token == "variable"
        define_variable(tokens)
      elsif token == "if"
        handle_if(tokens)
      elsif token == "do"
        handle_do_loop(tokens)
      elsif @variables.key?(token)
        @stack << token # Push variable name as a reference
      elsif @dictionary.key?(token)
        @dictionary[token].call
      elsif token =~ /^-?\d+$/
        @stack << token.to_i
      else
        raise UnknownWord, "Unknown word: #{token}"
      end
    end
  end

  private

  def define_variable(tokens)
    name = tokens.shift
    raise ForthError, "Missing variable name" if name.nil?
    @variables[name] = 0
  end

  def handle_if(tokens)
    check_stack(1)
    condition = @stack.pop
    
    true_part = []
    false_part = []
    current_part = true_part
    nesting = 0

    until tokens.empty?
      token = tokens.shift
      if token == "if"
        nesting += 1
        current_part << token
      elsif token == "else" && nesting == 0
        current_part = false_part
      elsif token == "then"
        if nesting == 0
          break
        else
          nesting -= 1
          current_part << token
        end
      else
        current_part << token
      end
    end

    to_execute = (condition != 0) ? true_part : false_part
    execute(to_execute) unless to_execute.empty?
  end

  def handle_do_loop(tokens)
    check_stack(2)
    index = @stack.pop
    limit = @stack.pop

    body = []
    nesting = 0
    found_loop = false
    until tokens.empty?
      token = tokens.shift
      if token == "do"
        nesting += 1
        body << token
      elsif token == "loop"
        if nesting == 0
          found_loop = true
          break
        else
          nesting -= 1
          body << token
        end
      else
        body << token
      end
    end
    raise ForthError, "Missing 'loop' for 'do'" unless found_loop

    (index...limit).each do |i|
      @loop_stack << i
      execute(body.dup)
      @loop_stack.pop
    end
  end

  def setup_builtins
    # Arithmetic
    @dictionary['+'] = -> { arithmetic_op { |a, b| a + b } }
    @dictionary['-'] = -> { arithmetic_op { |a, b| a - b } }
    @dictionary['*'] = -> { arithmetic_op { |a, b| a * b } }
    @dictionary['/'] = -> { arithmetic_op { |a, b| a / b } }

    # Stack manipulation
    @dictionary['dup']  = lambda {
      check_stack(1)
      @stack << @stack.last
    }
    @dictionary['drop'] = lambda {
      check_stack(1)
      @stack.pop
    }
    @dictionary['swap'] = lambda {
      check_stack(2)
      b = @stack.pop
      a = @stack.pop
      @stack << b
      @stack << a
    }
    @dictionary['over'] = lambda {
      check_stack(2)
      @stack << @stack[-2]
    }

    # Comparison
    @dictionary['='] = -> { arithmetic_op { |a, b| a == b ? -1 : 0 } }
    @dictionary['<'] = -> { arithmetic_op { |a, b| a < b ? -1 : 0 } }
    @dictionary['>'] = -> { arithmetic_op { |a, b| a > b ? -1 : 0 } }

    # Loops
    @dictionary['i'] = lambda {
      raise ForthError, "I outside of loop" if @loop_stack.empty?
      @stack << @loop_stack.last
    }
    @dictionary['j'] = lambda {
      raise ForthError, "J outside of nested loop" if @loop_stack.size < 2
      @stack << @loop_stack[-2]
    }

    # Variables
    @dictionary['@'] = lambda {
      check_stack(1)
      var_name = @stack.pop
      raise ForthError, "Not a variable" unless @variables.key?(var_name)
      @stack << @variables[var_name]
    }
    @dictionary['!'] = lambda {
      check_stack(2)
      var_name = @stack.pop
      value = @stack.pop
      raise ForthError, "Not a variable" unless @variables.key?(var_name)
      @variables[var_name] = value
    }
  end

  def arithmetic_op
    check_stack(2)
    b = @stack.pop
    a = @stack.pop
    @stack << yield(a, b)
  end

  def define_word(tokens)
    name = tokens.shift
    raise ForthError, "Missing word name in definition" if name.nil?
    raise ForthError, "Cannot redefine numbers" if name =~ /^-?\d+$/

    body = []
    found_semicolon = false
    until tokens.empty?
      token = tokens.shift
      if token == ';'
        found_semicolon = true
        break
      end
      body << token
    end
    raise ForthError, "Missing ';' in word definition" unless found_semicolon

    @dictionary[name] = -> { execute(body.join(' ')) }
  end

  def check_stack(n)
    raise StackUnderflow, "Stack underflow" if @stack.size < n
  end
end
