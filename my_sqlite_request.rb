require 'csv'
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

    def run_join_tables
        parsed_a = load_csv_hash(@table_name)
        parsed_b = load_csv_hash(@table_name_to_join)

        parsed_b.each do |row|
            criteria = {@join[:column_a] => row[@join[:column_b]]}
            row.delete(@join[:column_b])
            update_operation(parsed_a, criteria, row)
        end
        return parsed_a
    end

    def print_result(result)
        if !result
            return
        end
        if result.length == 0
            puts "Empty query"
            return
        else
            puts request.first.keys.join(' | ')
            puts '-' * request.first.keys.join(' | ').length
            result.each do |row|
                puts row.values.join(' | ')
            end
            puts '-' * request.first.keys.join(' | ').length
        end
    end

    def run 
        if @table_name != nil
            parsed_file = @table_name
        else
            puts "No table selected"
            return 
        end

        case @request
        when 'SELECT'
            if @join != nil
                parsed_file = run_join_tables
            end
            if @order != nil
                parsed_file = order_operation(parsed_file, @order[:order], @order[:column_name])
            end

            if @where != nil
                parsed_file = where_operation(parsed_file, {@where[:column_name] => @where[:criteria]})
            end

            if @columns != nil && @table_name != nil
                result = get_columns(parsed_file, @columns)
                print_result(result)
                return
            else
                puts "There is an error in you query"
            end
        when 'INSERT'
            if @data != nil
                parsed_file = insert_operation(parsed_file, @data)
            end
            write_to_file(parsed_file, @table_name)
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