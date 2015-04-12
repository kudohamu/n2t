require "./Command"

class Parser
  def initialize(file_name)
    @commands = Array.new

    File.open(file_name, "r") do |file|
      file.each_line do |line|
        trimmed_line = line.gsub(/\/\/.*/, "")
        trimmed_line = trimmed_line.gsub(/\s/, "") unless /\s+[^\s]+/ =~ trimmed_line
        @commands.push(trimmed_line) if trimmed_line.length != 0
      end
    end
    @index = -1
  end

  def has_more_commands?
    if (@index != @commands.length - 1)
      false
    else
      true
    end
  end

  def advance
    @index += 1
    case @commands[@index]
    when /\A\s*push[\s\w]+\Z/
      @command_type = Command::C_PUSH
    when /\A\s*pop[\s\w]+\Z/
      @command_type = Command::C_POP
    else
      @command_type = Command::C_ARITHMETIC
    end
  end

  def command_type
    @command_type
  end

  def arg1
    case @command_type
    when Command::C_ARITHMETIC
      @commands[@index].gsub(/\s*/, "")
    else
      @commands[@index].split("\s")[1]
    end
  end

  def arg2
    @commands[@index].split("\s")[2].to_i
  end
end
