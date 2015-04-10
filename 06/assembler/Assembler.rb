#!/usr/bin/env ruby

require "./Parser"
require "./Command"
require "./Code"
require "./SymbolTable"

@file_path = $*[0]
@hack_path = "#{File.basename(@file_path, ".*")}.hack"
@symbol_table = SymbolTable.new

def first_path
  binaries = Array.new
  parser = Parser.new(@file_path)
  while parser.has_more_commands?
    case parser.advance
    when Command::A_COMMAND
      binaries.push("@" + parser.symbol)
    when Command::L_COMMAND
      @symbol_table.add_entry(parser.symbol, binaries.length)
    when Command::C_COMMAND
      binaries.push(parser.dest + "=" + parser.comp + ";" + parser.jump)
    else
    end
  end
  File.open(@hack_path, "w:UTF-8:us-ascii") do |f|
    binaries.each do |line|
      f.puts line
    end
  end
end

def second_path
  binaries = Array.new
  ram_address = 16
  parser = Parser.new(@hack_path)
  while parser.has_more_commands?
    case parser.advance
    when Command::A_COMMAND
      symbol = parser.symbol
      if /\A[0-9]+\Z/ === symbol
        binaries.push("0" + format_symbol_binary(symbol.to_i))
      elsif @symbol_table.contains?(symbol)
        binaries.push("0" + format_symbol_binary(@symbol_table.get_address(symbol)))
      else
        @symbol_table.add_entry(symbol, ram_address)
        ram_address += 1
        binaries.push("0" + format_symbol_binary(@symbol_table.get_address(symbol)))
      end
    when Command::C_COMMAND
      binary = "111" + Code.comp(parser.comp) + Code.dest(parser.dest) + Code.jump(parser.jump)
      binaries.push(binary)
    else
    end
  end
  File.open(@hack_path, "w:UTF-8:us-ascii") do |f|
    binaries.each do |line|
      f.puts line
    end
  end
end

private
def format_symbol_binary(address)
  binary = address.to_s(2)
  if binary.length > 15
    raise "symbol's address(@#{address}) is too big"
  else
    (15 - binary.length).times do
      binary = "0" + binary
    end
  end
  binary
end

first_path
second_path
