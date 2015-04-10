require "./Command"

class Parser
  def initialize(file)
    @commands = Array.new
    File.open(file) do |file|
      file.each_line do |line|
        @commands.push(line)
      end
    end
    @commands
    @index = -1
  end

  def has_more_commands?
    if @index == @commands.length - 1
      false
    else
      true
    end
  end

  def advance
    @index += 1
    @commands[@index].gsub!(/\/\/.*/, "")
    @commands[@index].gsub!(/\s/, "")
    if @commands[@index].length == 0
      @command_type = Command::N_COMMAND
    elsif /\A@[A-z0-9\._$:]+\Z/ === @commands[@index]
      @symbol = @commands[@index].slice(/[A-z0-9\._$:]+/)
      @command_type = Command::A_COMMAND
    elsif /\A\([A-z\._$:][A-z0-9\._$:]*\)\Z/ === @commands[@index]
      @symbol = @commands[@index].slice(/[A-z\._$:][A-z0-9\._$:]*/)
      @command_type = Command::L_COMMAND
    else
      match = /\A([^=;]*?)=?([^=;]*);?([^=;]*)\Z/.match(@commands[@index])
      @dest = match[1]
      @comp = match[2]
      @jump = match[3]
      @command_type = Command::C_COMMAND
    end
    @command_type
  end

  def command_type
    @command_type
  end

  def symbol
    @symbol
  end

  def dest
    @dest
  end

  def comp
    @comp
  end

  def jump
    @jump
  end
end
