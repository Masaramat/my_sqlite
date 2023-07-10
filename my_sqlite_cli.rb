require 'readline'
require 'json'
require_relative "my_sqlite_request"
# method to get user inputs
def readline_with_hist_management
    line = Readline.readline('my_sqlite_cli> ', true)
    # return nil if line.nil?
    if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
    end
    line
end
# Converts arrays to hash for inputs in the methods 
def array_to_hash(arr)
    result = Hash.new
    i = 0
    while i < arr.length 
        left, right = arr[i].split("=")
        result[left] = right
        i += 1
    end
    return result
end
# Processes segments of command based on conditions
def process_action(action, args, request)
    case action
    when "from"
        if args.length != 1
            puts "Ex.: FROM db.csv"
            return
        else
            
            request.from(*args)
        end
    when "select"
        if args.length < 1
            puts "Ex.: SELECT name, age"
            return
        else 
            if args.join(", ") =="*"
                request.select_all
            end
            request.select(args.join(", "))                                 
                      
        end
    when "where"
        args = args.join(" ")
        if args[0].length != 1
            puts "Ex.: WHERE age=20"
        else
            # Splits the arguments irrespective of whitespaces  
           col, val = args.split(/\s*=\s*/, 2)
           
           request.where(col, val)
        end
    when "order"
        if args.length != 2
            p "Ex.: ORDER age ASC"
        else
            col_name = args[0]
            sort_type = args[1].downcase
            request.order(sort_type, col_name)
        end
    when "join"
        if args.length != 3
            puts "Do better. Ex.: JOIN table ON col_a=col_b"
        elsif args[1] != "ON"
            puts "Provide ON statement. Ex.: JOIN table ON col_a=col_b"
            return
        else
            table = args[0]
            col_a, col_b = args[2].split("=")
            request.join(col_a, table, col_b)
        end
    when "insert"
        if args.length != 1
            puts "Ex.: INSERT db.csv. Use VALUES"
        else
            request.insert(args[0].split(" ")[1])
        end
    when "values"
        
        if args.length < 1
            puts "Provide some data to insert. Ex.: name=BOB, birth_state=CA, age=90"
        else
            data = args.join(" ")
            data = data[1..-2]
            data_array = data.split(",")
            headers = CSV.read(request.table_name+".csv", headers: true).map(&:to_h).first.keys
            data_hash = headers.zip(data_array).to_h
            
            request.values(data_hash)
        end
    when "update"
        p args
        if args.length != 1
            p "Ex.: UPDATE db.csv"
        else
            request.update(*args)
           
        end
    when "set"
        if args.length < 1
            puts "Ex.: SET name=BOB. Use WHERE - otherwise WATCH OUT."
        else
            request.set(array_to_hash(args)) 
        end
    when "delete"         
        request.delete 
        
    else
        puts "There is an error in your sql"
        puts "type quit to exit."
    end
end
# Executes the request
def execute_request(sql)
    valid_actions = ["SELECT", "FROM", "JOIN", "WHERE", "ORDER", "INSERT", "VALUES", "UPDATE", "SET", "DELETE"]
    command = nil
    args = []
    request = MySqliteRequest.new
    splited_command = sql.split(" ")


    # Splits command written in CLI  into separate commands based on valid actions
    0.upto splited_command.length - 1 do |arg|
        # p splited_command[arg]
        if valid_actions.include?(splited_command[arg].upcase())
            if (command != nil) 
                if command != "JOIN"
                    args = args.join(" ").split(", ")
                end
                process_action(command, args, request)
                command = nil
                args = []
            end
            command = splited_command[arg].downcase()
        else
            args << splited_command[arg]
        end
    end   
    if args[-1].end_with?(";")
        args[-1] = args[-1].chomp(";")
        process_action(command, args, request)
        request.run
        puts "Executed"
    else
        p 'Finish your request with' ;
    end
end
# Starts up the CLI and get command and calls function to execute it
def run
    puts "MySQLite version 0.1 July, 2023"
    while command = readline_with_hist_management
        if command == "quit"
            break
        else
            execute_request(command)
        end
    end
end

run()

# Test run the project with the following commands

# --SELECT

# SELECT Player, collage FROM nba_players.csv;
# SELECT Player, collage FROM nba_players.csv WHERE sno = 125;
# SELECT Player, collage FROM nba_players.csv ORDER Player ASC;
# SELECT Player, collage FROM nba_players.csv WHERE collage = University of Kansas ORDER Player DESC;