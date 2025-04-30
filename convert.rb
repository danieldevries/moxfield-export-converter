require 'csv'

input_file = ARGV[0] || 'moxfield-export.txt'
output_file = ARGV[1] || 'exported.csv'

CSV.open(output_file, 'wb', col_sep: ';') do |csv|
  File.readlines(input_file).map do |line|
    amount, card_name, set, set_number, foil = line.strip.scan(/^(\d)+\s(.+)\s\((\w{3,4})\)\s(\S+)\s?(\*F\*)?/).first
    foil = foil == '*F*' ? 'Ja' : 'Nee'

    raise if [amount, card_name, set, set_number, foil].any? { _1.length == 0 }

    csv << [amount, card_name, set, foil]
  end
end

