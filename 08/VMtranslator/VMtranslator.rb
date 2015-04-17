#!/usr/bin/env ruby

require "./Parser"
require "./CodeWriter"
require "./Command"

@file_path = $*[0]
@asm_path = "#{File.basename(@file_path, ".*")}.asm"

def translate
  parser = Parser.new(@file_path)
  code_writer = CodeWriter.new(@asm_path)
  code_writer.write_init
  while !parser.has_more_commands?
    parser.advance
    case parser.command_type
    when Command::C_RETURN
      puts "return"
      code_writer.write_return
    when Command::C_PUSH, Command::C_POP
      code_writer.interpret_push_pop(parser.command_type, parser.arg1, parser.arg2)
    when Command::C_FUNCTION
      puts "function"
      code_writer.write_function(parser.arg1, parser.arg2)
    when Command::C_CALL
    when Command::C_IF
      code_writer.write_if(parser.arg1)
    when Command::C_GOTO
      code_writer.write_goto(parser.arg1)
    when Command::C_LABEL
      code_writer.write_label(parser.arg1)
    else
      code_writer.interpret_arithmetic(parser.arg1)
    end
  end
  code_writer.close
end

translate
