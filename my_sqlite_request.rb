require 'csv'
require 'json'
require_relative 'database_ops.rb'

class MySqliteRequest

    def initialize

    end

    def from(table_name)
        if table_name != nil
            @table_name = table_name
        else
            puts "Please provide a valid table name"
        end
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
        @where = {column: column_name, value: criteria}
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

    end

    def set(data)
        @data = data
        return self

    end

    def delete
        @request = 'DELETE'
        return self

    end


    def print_result(result)
        if !result
            return
        end
        if result.length == 0
            puts "Empty query"
            return
        else
            puts "result: \n"
            puts result.first.keys.join(' | ')
            puts '-' * result.first.keys.join(' | ').length
            result.each do |row|
                puts row.values.join(' | ')
            end
            puts '-' * result.first.keys.join(' | ').length
        end
    end
    

    def run 
        if @table_name != nil
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
                csv_b = CSV.read(@table_name_to_join, headers: true).map(&:to_h)
                csv_a = csv_hash
                join_records = []
                csv_a.each do |record_a|
                    csv_b.each do |record_b|
                        if record_a[@join[:column_a].to_s] == record_b[@join[:column_b].to_s]
                            join_records << record_a.merge(record_b)
                        end
                    end
                end
                csv_hash = join_records

            end
            if @order != nil
                csv_hash = csv_hash.sort_by {|record| record[@order[:column_name].to_s]}
                csv_hash.reverse! if @order[:order] == 'desc'
            end

            if @where != nil
                csv_hash = csv_hash.select do |record|
                    record[@where[:column].to_s] == @where[:value]
                end
            end

            if @columns != nil && @table_name != nil 
                csv_hash.each do |record|
                    res = {}
                    
                    @columns.split(',').map(&:strip).each do |column|
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
            if @data != nil && @table_name != nil
                csv_hash = CSV.open(@table_name, 'a') do |csv|
                    @data.each do |row|
                        csv << row.values
                    end
                end
            end
            print_result(csv_hash)
            
        when 'UPDATE'
            if @where != nil 
                @where = {@where[:column_name] => @where[:criteria]}
            end
            parsed_file = update_operation(parsed_file, @where, @data)
            write_to_file(parsed_file, @table_name)
        when 'DELETE'
            if @where != nil 
                @where = {@where[:column_name] => @where[:criteria]}
            end
            parsed_file = delete_operation(parsed_file, @where)
            write_to_file(parsed_file, @table_name)
        end

        @request = nil
        @where = nil
        @table_name = nil
        @data = nil
        @join = nil
    end

end

request = MySqliteRequest.new
request = request.from('nba_player_data.csv')
request = request.select('name, birth_date, position, college')
# request = request.join('college', 'nba_players.csv', 'college')
request = request.order('asc', 'name')
# request = request.insert('nba_player_data.csv')
# request = request.values([
#     {'name' => 'innocent Mangut', 'year_start' => '1990', 'year_end'=>'1999', 'position' => 'FF-10', 'height' => '3.56', 'weight' => '300', 'birth_date'=> 'June 24, 1968', 'college'=>'Jos University'},
#     {'name' => 'innocent Silas', 'year_start' => '1990', 'year_end'=>'1999', 'position' => 'FF-10', 'height' => '3.56', 'weight' => '300', 'birth_date'=> 'June 24, 1968', 'college'=>'Jos University'}
# ])


request.run