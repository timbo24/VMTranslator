
class CodeWriter
	SEGMENTS = {"argument"=>"ARG", "local"=>"LCL", "this"=>"THIS", "that"=>"THAT"}
	POINTER_TEMP = {"pointer"=>"3", "temp" =>"5"}
	ASSEMBLY_COMMANDS = {"D=Y,SPonX"=> "    @SP\n" +
					 "    M=M-1\n" +
					 "    A=M\n" +
					 "    D=M\n" +
					 "    @SP\n" +
					 "    A=M-1\n",
			    "D=Y"=>       "    @SP\n" +
					 "    M=M-1\n" +
					 "    A=M\n" +
					 "    D=M\n",
			    "DtoSt"=>     "    @SP\n" +
					 "    A=M\n" +
					 "    M=D\n" +
					 "    @SP\n" +
					 "    M=M+1\n",
			    "PopAddress"=>"    D=D+A\n" +
					 "    @13\n" +
					 "    M=D\n" +
					 "    @SP\n" +
					 "    M=M-1\n" +
					 "    A=M\n" +
					 "    D=M\n" +
					 "    @13\n" +
					 "    A=M\n" +
					 "    M=D\n",
			    "ASP-"=>      "    @SP\n" +
					 "    A=M-1\n",
			    "add"=>      "    M=D+M\n",
			    "sub"=>       "    M=M-D\n",
			    "and"=>       "    M=D&M\n",
			    "or"=>        "    M=D|M\n",
			    "neg"=>       "    M=-M\n",
			    "not"=>       "    M=!M\n",
			    "eq"=>        "    D;JEQ\n",
			    "gt"=>        "    D;JGT\n",
			    "lt"=>        "    D;JLT\n"}

	public
	def initialize(commands, file_path, file_name)
		@inc = 0
		@commands = commands
		@file_name = file_name
		@file = File.new(file_path << "/" <<  file_name << ".asm", "w")
	end


	def translate
		@commands.each do |command|
			case command[0]
			when "C_ARITHMETIC"
				write_arithmetic(command[1])
			when "C_PUSH"
				write_push(command)
			when "C_POP"
				write_pop(command)
			when "C_FILENAME"
				fName = command[1]
			end
		end
		@file.close
	end

	private
	def write_arithmetic(operator) 
		if operator == "add" || operator == "sub" || operator == "and" || operator ==  "or"
			@file.puts(ASSEMBLY_COMMANDS["D=Y,SPonX"] +
				   ASSEMBLY_COMMANDS[operator])
		elsif operator == "neg" || operator =="not"
			@file.puts(ASSEMBLY_COMMANDS["ASP-"] +
				   ASSEMBLY_COMMANDS[operator])
		elsif operator == "eq" || operator == "gt" || operator == "lt"
			@file.puts(ASSEMBLY_COMMANDS["D=Y,SPonX"] +
				  "    D=M-D\n" +
				  "    @T" + @inc.to_s + "\n" +
				  ASSEMBLY_COMMANDS[operator] +
				  ASSEMBLY_COMMANDS["ASP-"] +
				  "    M=0\n" +
				  "    @E" + @inc.to_s + "\n" +
				  "    0;JMP\n" +
				  "(T" + @inc.to_s + ")\n" +
				  ASSEMBLY_COMMANDS["ASP-"] +
				  "    M=-1\n" +
				  "(E" + @inc.to_s + ")\n")
		end
		@inc += 1
	end



	def write_push(command)
		if command[1] == "constant"
			@file.puts("    @" + command[2].to_s + "\n" +
				"    D=A\n" +
				ASSEMBLY_COMMANDS["DtoSt"])
		elsif command[1] == "static"
			seg = @file_name + "." + command[2].to_s
			@file.puts("    @" + seg + "\n" + 
				"    D=M\n" +
				ASSEMBLY_COMMANDS["DtoSt"])
		elsif POINTER_TEMP.include?(command[1])
			seg = POINTER_TEMP[command[1]]
			@file.puts("    @" + seg +"\n")
			if command[2] > 1
			    @file.puts("    D=A\n" +
				    "    @" + command[2].to_s + "\n" +
			    "    A=D+A\n")
			elsif command[2] == 1
			    @file.puts("A=A+1\n")
			end
			@file.puts("    D=M\n" +
				ASSEMBLY_COMMANDS["DtoSt"])
		else
			seg = SEGMENTS[command[1]]
			@file.puts("    @" + seg +"\n")
			if command[2] > 1
			    @file.puts("    D=M\n" +
				    "    @" + command[2].to_s + "\n" +
				    "    A=D+A\n")
			elsif command[2] == 0
			    @file.puts("    A=M\n")
			else
			    @file.puts("    A=M+1\n")
			end
			@file.puts("    D=M\n" +
				ASSEMBLY_COMMANDS["DtoSt"])
		end
	end


	def write_pop(command)
		if command[1] == "constant"
			@file.puts("    @SP\n" +
			"    M=M-1\n")
		elsif command[1] == "static"
			seg = @file_name + "." + command[2].to_s    
			@file.puts(ASSEMBLY_COMMANDS["D=Y"] +
				"    @" + seg + "\n" +
				"    M=D\n")
		elsif POINTER_TEMP.include?(command[1])
			seg = POINTER_TEMP[command[1]]
			if command[2] > 1
			    @file.puts("    @" + seg + "\n" +
				    "    D=A\n" +
				    "    @" + command[2].to_s + "\n"+
				    ASSEMBLY_COMMANDS["PopAddress"]) 
			else 
			    @file.puts(ASSEMBLY_COMMANDS["D=Y"] + 
				    "    @" + seg + "\n")
			    if command[2] == 1
				@file.puts("    A=A+1\n")
			    end
			    @file.puts("    M=D\n")
			end
		else
			seg = SEGMENTS[command[1]]
			if command[2] > 1
			    @file.puts("    @" + seg + "\n" +
				    "    D=M\n" +
				    "    @" + command[2].to_s + "\n" + ASSEMBLY_COMMANDS["PopAddress"])
			else   
				@file.write(ASSEMBLY_COMMANDS["D=Y"] +
				    "    @" + seg + "\n" + "    A=M") 
				if command[2] == 0
					@file.puts("\n")
				else
					@file.puts("+1\n")
				end
				@file.puts("    M=D\n") 
			end
		end
	end
end
