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

    @return = 0
    @current_function = ""
    @jump_point = 0

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
    add_codes([
      '@256',
      'D=A',
      "@#{@sp}",
      'M=D'
    ])

    write_call('Sys.init', 0)
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
        #if (0 <= index && index <= 32767)
          add_codes([
            "@#{index}",
            'D=A',
            "@#{@sp}",
            'A=M',
            "M=D",
            "@#{@sp}",
            'M=M+1'
          ])
        #else
          #raise 'InvalidConstantNumber'
        #end
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
        raise "PUSHSegmentError"
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
      else
        raise "POPSegmentError"
      end
    else
      raise "CommandError"
    end
  end

  def write_label(label)
    add_codes(["(#{create_label(label)})"])
  end

  def write_goto(label)
    add_codes([
      "@#{create_label(label)}",
      '0;JMP'
    ])
  end

  def write_if(label)
    add_codes([
      "@#{@sp}",
      'M=M-1',
      'A=M',
      'D=M',
      "@#{create_label(label)}",
      'D;JNE'
    ])
  end

  def write_call(function_name, num_args)
    return_address = "return-address.#{@return}"
    @return += 1

    interpret_push_pop(Command::C_PUSH, 'constant', return_address)

    add_codes([
      "@#{@lcl}",
      'D=M',
      "@#{@sp}",
      'A=M',
      'M=D',
      "@#{@sp}",
      'M=M+1'
    ])

    add_codes([
      "@#{@arg}",
      'D=M',
      "@#{@sp}",
      'A=M',
      'M=D',
      "@#{@sp}",
      'M=M+1'
    ])

    add_codes([
      "@#{@this}",
      'D=M',
      "@#{@sp}",
      'A=M',
      'M=D',
      "@#{@sp}",
      'M=M+1'
    ])

    add_codes([
      "@#{@that}",
      'D=M',
      "@#{@sp}",
      'A=M',
      'M=D',
      "@#{@sp}",
      'M=M+1'
    ])

    add_codes([
      "@#{@sp}",
      'D=M',
      "@#{num_args}",
      'D=D-A',
      '@5',
      'D=D-A',
      "@#{@arg}",
      'M=D'
    ])

    add_codes([
      "@#{@sp}",
      'D=M',
      "@#{@lcl}",
      'M=D'
    ])

    write_goto(function_name)
    add_codes(["(#{return_address})"])
  end

  def write_return
    add_codes([
      "@#{@lcl}",
      'D=M',
      '@13', #frame
      "M=D"
    ])

    add_codes([
      '@5',
      'D=A',
      '@13',
      'A=M-D', #*(frame-5)
      'D=M', 
      '@14', #ret
      'M=D' #ret=*(frame-5)
    ])

    interpret_push_pop(Command::C_POP, 'argument', 0)

    add_codes([
      "@#{@arg}",
      'D=M',
      "@#{@sp}",
      'M=D+1', #sp=arg+1
    ])

    add_codes([
      '@1',
      'D=A',
      '@13', #frame
      'A=M-D', #*(frame-1)
      'D=M',
      "@#{@that}",
      'M=D' #that=*(frame-1)
    ])

    add_codes([
      '@2',
      'D=A',
      '@13', #frame
      'A=M-D', #*(frame-2)
      'D=M',
      "@#{@this}",
      'M=D' #this=*(frame-2)
    ])

    add_codes([
      '@3',
      'D=A',
      '@13', #frame
      'A=M-D', #*(frame-3)
      'D=M',
      "@#{@arg}",
      'M=D' #arg=*(frame-3)
    ])

    add_codes([
      '@4',
      'D=A',
      '@13', #frame
      'A=M-D', #*(frame-4)
      'D=M',
      "@#{@lcl}",
      'M=D' #lcl=*(frame-4)
    ])

    add_codes([
      '@14', #ret
      'A=M',
      '0;JMP'
    ])
  end

  def write_function(function_name, num_locals)
    codes = [
      "(#{function_name})"
    ]
    add_codes(codes)
    num_locals.times do
      interpret_push_pop(Command::C_PUSH, 'constant', 0)
    end
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
      "@jump_point.#{@jump_point}", #set jump_point
      "D;J#{op.upcase}",
      "@#{@sp}",
      'A=M', #x
      'M=0', #x=false
      "(jump_point.#{@jump_point})",
      "@#{@sp}", #jump_point
      'M=M+1', #sp=sp+1
    ])
    @jump_point += 1
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

  private
  def create_label(label)
    if @current_function == ""
      label
    else
      "#{@current_function}$#{label}"
    end
  end
end
