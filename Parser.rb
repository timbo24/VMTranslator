#class that is used to parse a single .vm file

class Parser
	#list defining aritmetic operators
	ARITHMETIC = ['add', 'sub', 'neg', 'eq', 'gt', 'lt', 'and', 'or', 'not']

	#command types with corresponding operators
	COMMAND_TYPES = { 'pop'      => 'C_POP', 
		          'push'     => 'C_PUSH', 
			  'label'    => 'C_LABEL', 
			  'goto'     => 'C_GOTO', 
			  'if-goto'  => 'C_IF', 
			  'function' => 'C_FUNCTION', 
			  'return'   => 'C_RETURN', 
			  'call'     => 'C_CALL' }

	#multi-argument commands
	MULTI_ARG_COMMANDS = ['C_PUSH', 'C_POP', 'C_FUNCTION', 'C_CALL']

	public
	#keeps track of commands that have been parsed
	attr_reader :commands

	#initializes the commands member
	def initialize(file_path)
		@file_path = file_path
		@commands = []
		@file_name = file_path[file_path.rindex('/') + 1 ... file_path.rindex('.')]
	end

	#opens the file based on the file_path initialized with the parser
	#this method will parse line by line the file and decompose it into the 
	#array of commands, along with their corresponding arguments
	def parse
		file = File.read(@file_path)
		@commands.push(['C_FILENAME', @file_name])

		file.each_line do |line|
			next if line.strip == '' || line[0...2] == '//'

			tokens = line.split

			command = command_type(tokens[0])
			arg1 = argument_1(tokens, command)

			if MULTI_ARG_COMMANDS.include?(command)
				arg2 = tokens[2].to_i
				@commands.push([command, arg1, arg2])
			else
				@commands.push([command, arg1])
			end
		end
	end

	private
	#helper method will return the command type based on 
	#the read in line from the file, if it is any one of the 9
	#arithmetic commands, that's returned
	def command_type(arg)
		ARITHMETIC.include?(arg) ? 'C_ARITHMETIC' : COMMAND_TYPES[arg]
	end

	#helper method that returns the first argument
	#of the line
	def argument_1(tokens, command)
		command == 'C_ARITHMETIC' ? tokens[0] : tokens[1]
	end
end
