require "./Register"

class CodeWriter
  def initialize(file_name)
    @file_name = file_name
    @ram = Register.new
    @codes = Array.new
  end

  def interpret_arithmetic(command)
    case command
    when 'add'
      double_calculation('+')
    when 'sub'
      double_calculation('-')
    when 'neg'
      single_calculation('-')
    when 'eq'
      double_comparision(command)
    when 'gt'
      double_comparision(command)
    when 'lt'
      double_comparision(command)
    when 'and'
      double_calculation('&')
    when 'or'
      double_calculation('|')
    when 'not'
      single_calculation('!')
    else
    end
  end

  def interpret_push_pop(command, segment, index)
    case command
    when Command::C_PUSH
      case segment
      when 'constant'
        if (0 <= index && index <= 32767)
          @codes.push("@#{index}")
          @codes.push('D=A')
          @codes.push('@0')
          @codes.push('A=M')
          @codes.push("M=D")
          @codes.push('@0')
          @codes.push('M=M+1')
        else
          raise 'InvalidConstantNumber'
        end
      else
      end
    when Command::C_POP
    else
    end
  end

  def close
    @codes.push('@' + @codes.length.to_s)
    @codes.push('0;JMP')
    File.open(@file_name, 'w:us-ascii:us-ascii') do |f|
      @codes.each do |code|
        f.puts code
      end
    end
  end

  private
  def single_calculation(op)
    @codes.push('@0')
    @codes.push('M=M-1') #sp=sp-1
    @codes.push('A=M') #y
    @codes.push('M='+op+'M')
    @codes.push('@0')
    @codes.push('M=M+1') #sp=sp+1
  end

  def double_calculation(op)
    @codes.push('@0')
    @codes.push('M=M-1') #sp=sp-1
    @codes.push('A=M') #y
    @codes.push('D=M') #D=y
    @codes.push('@0')
    @codes.push('M=M-1') #sp=sp-1
    @codes.push('A=M') #x
    @codes.push('M=M'+op+'D')
    @codes.push('@0')
    @codes.push('M=M+1') #sp=sp+1
  end

  def double_comparision(op)
    @codes.push('@0')
    @codes.push('M=M-1') #sp=sp-1
    @codes.push('A=M') #y
    @codes.push('D=M') #D=y
    @codes.push('@0')
    @codes.push('M=M-1') #sp=sp-1
    @codes.push('A=M') #x
    @codes.push('D=M-D')
    @codes.push('M=-1') #x=true
    @codes.push('@' + (@codes.length + 5).to_s) #set jump_point
    @codes.push('D;J'+op.upcase)
    @codes.push('@0')
    @codes.push('A=M') #x
    @codes.push('M=0') #x=false
    @codes.push('@0') #jump_point
    @codes.push('M=M+1') #sp=sp+1
  end
end
