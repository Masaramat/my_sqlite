require 'csv'
require 'json'

class MySqliteRequest
    attr_reader :table_name 

    def initialize
        @where = []

    end

    def from(table_name)
        if table_name != nil
            @table_name = table_name
        else
            puts "Please provide a valid table name"
        end
        return self
    end

    def select_all
        @select_all = true
        return self
    end

    def select(columns)
        if columns != nil
            @request = "SELECT"
            @columns = columns
        end
        return self
    end

    def where(column_name, criteria)        
        @where << {column: column_name, value: criteria}
        return self

    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        @join = {column_a: column_on_db_a, column_b: column_on_db_b}
        @table_name_to_join = filename_db_b
        return self;

    end

    def order(order, column_name)
        @order = {order: order, column_name: column_name}
        return self

    end

    def insert(table_name)
        @request = 'INSERT'
        @table_name = table_name
        return self

    end

    def values(data)
        @data = data
        return self

    end

    def update(table_name)
        @request = 'UPDATE'
        @table_name = table_name
        return self

    end

    def set(data)
        @data = data
        return self
    end

    def delete
        @request = 'DELETE'
        return self

    end

    def delete_all_records(table_name)
        # Read the CSV file 
        data = CSV.read(table_name)
        
        # Save the header row into this variable
        header = data[0]
        
        # Deletes all contents of the csv
        data.clear
        # Writes the header back to the data array
        data << header
        
        # Write the Header back to the file
        CSV.open(table_name, 'w') do |csv|
          data.each { |row| csv << row }
        end        
        puts "All records deleted from #{table_name}."
    end
    
      

    # method to print the result of query execution
    def print_result(result)
        if !result
            return
        end
        if result.length == 0
            puts "Empty query"
            return
        else
            puts "result: \n"
            # peints the headers of the hash given
            puts result.first.keys.join(' | ')
            puts '-' * result.first.keys.join(' | ').length
            result.each do |row|
                # prints the values of the hash 
                puts row.values.join(' | ')
            end
            puts '-' * result.first.keys.join(' | ').length
        end
    end
    
    # Runs the class with the curent status of the request
    def run 
        # Table must be given 
        if @table_name != nil
            if !@table_name.end_with?(".csv")
                @table_name = "#{@table_name}.csv"
            end
            csv_hash = CSV.read(@table_name, headers: true)
            csv_hash = csv_hash.map(&:to_h)
        else
            puts "No table selected"
            return 
        end

        case @request
        when 'SELECT'
            result = []
            if @join != nil
                # opens both csv files 
                csv_b = CSV.read(@table_name_to_join, headers: true).map(&:to_h)
                csv_a = csv_hash
                # to store the final join result
                join_records = []
                csv_a.each do |record_a|
                    csv_b.each do |record_b|
                        # merges the selected records into one file joined_records
                        if record_a[@join[:column_a].to_s] == record_b[@join[:column_b].to_s]
                            join_records << record_a.merge(record_b)
                        end
                    end
                end
                # updates the hash result to include only the joined result
                csv_hash = join_records

            end
            if @order != nil
                # orders the result of the querry
                csv_hash = csv_hash.sort_by {|record| record[@order[:column_name].to_s]}
                csv_hash.reverse! if @order[:order] == 'desc'
            end

            if @where != nil
                # implements where to select only selected records
                @where.each do |condition|
                    csv_hash = csv_hash.select do |record|
                        record[condition[:column].to_s] == condition[:value]
                    end
                    
                end
            end
            if @select_all
                result = csv_hash
                print_result(result)
                return
            end
            # final block that performs the select and prints the result using print_result function
            if @columns != nil && @table_name != nil 

                csv_hash.each do |record|
                    res = {}
                    # slits the string given as the colum into array for easier fetching
                    @columns.split(', ').each do |column|
                        value = record[column]
                        res[column] = value
                    end
                    result << res
                end                
                print_result(result)
                return
            else 
                puts "There is an error in you query"
            end
        when 'INSERT'
            csv_result = []
            if @data != nil && @table_name != nil
                # opens and append records to the csv file using csv_hash
                csv_hash = CSV.open(@table_name, 'a') do |csv|                   
                    csv <<  @data.values 
                                                        
                end  
                csv_result << @data
                print_result(csv_result)              
                
            end            
           
       
        when 'UPDATE'            
            # gets the record using the where clause
            csv_hash.select do |record|
                if @where.length > 0
                    @where.each do |condition|
                        if record[condition[:column].to_s] == condition[:value]
                            record.merge!(@data)
                        end
                    end

                else
                #    Updates all records if where condition is not supplied
                    record.merge!(@data)                    
                end

            end
            # writes the updated record to the csv file
            CSV.open(@table_name, 'w', write_headers: true, headers: csv_hash.first.keys) do |csv|
                csv_hash.each {|row| csv << row.values }
            end

            
            
        when 'DELETE'
            
            if @where.length > 0
                # deletes records from the hash file with where condition
                @where.each do |condition|
                    csv_hash.reject! do |record|
                        record[condition[:column].to_s] == condition[:value]            
                        
                    end
                    # writes the result to the csv file
                    CSV.open(@table_name, 'w', write_headers: true, headers: csv_hash.first.keys) do |csv|
                        csv_hash.each {|row| csv << row.values }
                    end
                end
            else
                # puts "deleting all records"
                # Deletes all records from csv file if where condition is not specified                
                delete_all_records(@table_name)                    
            end

        end
        # set all variables to nill 
        @request = nil
        @where = nil
        @table_name = nil
        @data = nil
        @join = nil
    end

end



