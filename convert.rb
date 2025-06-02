require 'csv'

class MoxfieldConverter
  attr_reader :file_contents, :output_file_path, :skipped, :lines

  def initialize(file_contents, output_file_path)
    @file_contents = file_contents
    @output_file_path = output_file_path
    @skipped = []
    @lines = []
  end

  def run
    file_contents.each do |line|
      amount, card_name, set, set_number, foil = line.strip.scan(/^(\d)+\s(.+)\s\((\w{3,4})\)\s(\S+)\s?(\*F\*)?/).first
      foil = foil == '*F*' ? 'Ja' : 'Nee'

      if [amount, card_name, set, set_number, foil].any? { _1.length == 0 }
        skipped << [amount, card_name, set, set_number, foil]
      end

      lines << [amount, card_name, set, foil]
    end

    if skipped.none?
      output = CSV.generate_lines(lines, col_sep: ';')
      File.open(output_file_path, 'w') { |file| file.write(output) }

      puts "Saved file to #{output_file_path}"
    else
      puts "Not all lines could be parsed:"
      puts skipped
    end
  end
end

if __FILE__ == $0
  require 'optparse'

  options = {}
  option_parser = OptionParser.new do |opt|
    opt.on('-i INPUT') { |value| options[:input_file] = value }
    opt.on('-o INPUT') { |value| options[:output_file] = value }
  end
  option_parser.parse!

  input_file_path = options[:input_file] || 'moxfield-export.txt'
  file_contents = File.readlines(input_file_path)

  output_file_path = options[:output_file] || 'order.csv'

  converter = MoxfieldConverter.new(file_contents, output_file_path)
  converter.run
end

