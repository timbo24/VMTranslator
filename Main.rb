
require_relative 'Parser'
require_relative 'CodeWriter'


print "VMTranslator "
file_path = gets.chomp
file_path.strip
file_path = file_path[0..-2] if file_path[-1] == "/" 

commands = []

if File.file?(file_path)
	file_parser = Parser.new(file_path)
	file_parser.parse
	commands += file_parser.commands
	parsed_files.push(file_parser)
elsif File.directory?(file_path)
	file_name = file_path[file_path.rindex("/") + 1 .. -1]
	Dir.entries(file_path).each do |file|
		next unless file[-3..-1] == ".vm"
		file_parser = Parser.new(file_path << "/" << file)
		file_parser.parse
		commands += file_parser.commands
	end
else
	puts "Invalid file or directory"
	
end

file_path = file_path[0 ... file_path.rindex("/")]
	
writer = CodeWriter.new(commands, file_path, file_name)
writer.translate

