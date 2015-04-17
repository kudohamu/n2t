class CodeWriter
  def initialize(file_name)
    @file_name = file_name
    @codes = Array.new

    @sp   = 0
    @lcl  = 1
    @arg  = 2
    @this = 3
    @that = 4
    @temp = 5

    @op_map = {
      'add' => '+',
      'sub' => '-',
      'neg' => '-',
      'and' => '&',
      'or'  => '|',
      'not' => '!'
    }
  end

  def write_init

  end

  def interpret_arithmetic(command)
    case command
    when 'add', 'sub', 'and', 'or'
      double_calculation(@op_map[command])
    when 'neg', 'not'
      single_calculation(@op_map[command])
    when 'eq', 'gt', 'lt'
      double_comparision(command)
    else
    end
  end

  def interpret_push_pop(command, segment, index)
    case command
    when Command::C_PUSH
      case segment
      when 'constant'
        if (0 <= index && index <= 32767)
          add_codes([
            "@#{index}",
            'D=A',
            "@#{@sp}",
            'A=M',
            "M=D",
            "@#{@sp}",
            'M=M+1'
          ])
        else
          raise 'InvalidConstantNumber'
        end
      when 'local', 'argument', 'this', 'that', 'temp'
        if (segment == 'temp')
          if (index < 0 || 7 < index)
            raise "IllegalTempIndex"
          end
        end

        add_codes([
          "@#{index}",
          'D=A',
          "@#{get_segment_base_index(segment)}",
          'A=M+D',
          "D=M",
          "@#{@sp}",
          'A=M',
          'M=D',
          "@#{@sp}",
          'M=M+1'
        ])
      when 'pointer'
        pointer = if (index == 0) 
                    @this
                  elsif (index == 1)
                    @that
                  else
                    raise "IllegalPointerIndex"
                  end
        add_codes([
          "@#{pointer}",
          'D=M',
          "@#{@sp}",
          'A=M',
          'M=D',
          "@#{@sp}",
          'M=M+1'
        ])
      when 'static'
        add_codes([
          "@#{File.basename(@file_name, ".*")}.#{index}",
          'D=M',
          "@#{@sp}",
          'A=M',
          'M=D',
          "@#{@sp}",
          'M=M+1'
        ])
      else
      end
    when Command::C_POP
      case segment
      when 'local', 'argument', 'this', 'that', 'temp'
        if (segment == 'temp')
          if (index < 0 || 7 < index)
            raise "IllegalTempIndex"
          end
        end

        add_codes([
          "@#{index}",
          'D=A',
          "@#{get_segment_base_index(segment)}",
          'M=M+D',
          "@#{@sp}",
          'M=M-1',
          'A=M',
          'D=M',
          "@#{get_segment_base_index(segment)}",
          'A=M',
          'M=D',
          "@#{index}",
          'D=A',
          "@#{get_segment_base_index(segment)}",
          'M=M-D'
        ])
      when 'pointer'
        pointer = if (index == 0) 
                    @this
                  elsif (index == 1)
                    @that
                  else
                    raise "IllegalPointerIndex"
                  end
        add_codes([
          "@#{@sp}",
          'M=M-1',
          'A=M',
          'D=M',
          "@#{pointer}",
          'M=D'
        ])
      when 'static'
        add_codes([
          "@#{@sp}",
          'M=M-1',
          'A=M',
          'D=M',
          "@#{File.basename(@file_name, ".*")}.#{index}",
          'M=D'
        ])
      end
    else
    end
  end

  def write_label(label)
    add_codes(["(#{label})"])
  end

  def write_goto(label)
    add_codes([
      "@#{label}",
      '0;JMP'
    ])
  end

  def write_if(label)
    add_codes([
      "@#{@sp}",
      'M=M-1',
      'A=M',
      'D=M',
      "@#{label}",
      'D;JNE'
    ])
  end

  def write_call(function_name, num_args)

  end

  def write_return

  end

  def write_function(function_name, num_locals)

  end

  def close
    add_codes([
      '(END)',
      '@END',
      '0;JMP'
    ])
    File.open(@file_name, 'w:us-ascii:us-ascii') do |f|
      @codes.each do |code|
        f.puts code
      end
    end
  end

  private
  def single_calculation(op)
    add_codes([
      "@#{@sp}",
      'M=M-1', #sp=sp-1
      'A=M', #y
      "M=#{op}M",
      "@#{@sp}",
      'M=M+1' #sp=sp+1
    ])
  end

  def double_calculation(op)
    add_codes([
      "@#{@sp}",
      'M=M-1', #sp=sp-1
      'A=M', #y
      'D=M',
      "@#{@sp}",
      'M=M-1', #sp=sp-1
      'A=M', #x
      "M=M#{op}D",
      "@#{@sp}",
      'M=M+1', #sp=sp+1
    ])
  end

  def double_comparision(op)
    add_codes([
      "@#{@sp}",
      'M=M-1',
      'A=M', #y
      'D=M',
      "@#{@sp}",
      'M=M-1',
      'A=M', #x
      'D=M-D',
      'M=-1', #x=true
      "@#{@codes.length + 5 + 9}", #set jump_point
      "D;J#{op.upcase}",
      "@#{@sp}",
      'A=M', #x
      'M=0', #x=false
      "@#{@sp}", #jump_point
      'M=M+1', #sp=sp+1
    ])
  end

  def get_segment_base_index(segment)
    case segment
    when 'local'
      @lcl
    when 'argument'
      @arg
    when 'this'
      @this
    when 'that'
      @that
    when 'temp'
      @temp
    end
  end

  def add_codes(codes)
    codes.each do |code|
      @codes.push(code)
    end
  end
end
