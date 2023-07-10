# Welcome to My Sqlite
This project is a replication of SQL queries which is made by ruby cli 

## Task
The project is to create an application to perform the same tasks as the sql commands
1. It should be able to create records in a csv file
2. It should be able to select records from the csv file
3. it should be able to update and delete records

## Description
The project is devided into two parts the my_sqlite_request.rb which implements the request class and the methods to perform the database 
queries on the csv file and the my-sqlite_cli.rb which interacts with the user. It receives the commands and calls the request class to perform the commands given by the user.

## Installation
Clone the project into a directory on a machine that has ruby installed. You can also run it on Docode as the project requires

## Usage
In order to run the project; 
1. open the project with on a terminal/command prompt and run the commands 
```bash
    ruby my_sqlite_cli.rb

```
2. once the command runs successfully, you can proceed to test the code with the following commands:

```bash
    SELECT * FROM students
    SELECT name,email FROM students WHERE name = 'Mila'
    INSERT INTO students VALUES (John,john@johndoe.com,A,https://blog.johndoe.com)
    UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Mila'
    DELETE FROM students WHERE name = 'John'
```
Provided a csv file named students exists and meets up the above criteria
3. copy any of the snippets below and paste at the end of the file my_sqlite_request.rb
```ruby
    # Testing select name
    request = MySqliteRequest.new
    request = request.from('nba_player_data.csv')
    request = request.select('name')
    request.run

    # Testing select with condition
    request = MySqliteRequest.new
    request = request.from('nba_player_data.csv')
    request = request.select('name')
    request = request.where('college', 'University of California')
    request.run

    # Testing select with multiple conditions
    request = MySqliteRequest.new
    request = request.from('nba_player_data.csv')
    request = request.select('name')
    request = request.where('college', 'University of California')
    request = request.where('year_start', '1997')
    request.run

    # Testing insert
    request = MySqliteRequest.new
    request = request.insert('nba_player_data.csv')
    request = request.values('name' => 'Alaa Abdelnaby', 'year_start' => '1991', 'year_end' => '1995', 'position' => 'F-C', 'height' => '6-10', 'weight' => '240', 'birth_date' => "June 24, 1968", 'college' => 'Duke University')
    request.run

    # Testing update with condition
    request = MySqliteRequest.new
    request = request.update('nba_player_data.csv')
    request = request.values('name' => 'Alaa Renamed')
    request = request.where('name', 'Alaa Abdelnaby')
    request.run

    # Testing update without condition (Very dangerous)
    request = MySqliteRequest.new
    request = request.update('nba_player_data.csv')
    request = request.values('name' => 'Alaa Renamed')
    request.run

    # Testing delete with condition (Very dangerous)
    request = MySqliteRequest.new
    request = request.delete()
    request = request.from('nba_player_data.csv')
    request.run

    # Testing delete without condition
    request = MySqliteRequest.new
    request = request.delete()
    request = request.from('nba_player_data.csv')
    request = request.where('name', 'Alaa Abdelnaby')
    request.run

```

4. To test the methods you type quit on the cli running and run the request class like so:
```bash
    ruby my_sqlite_request.rb

```


### The Core Team
Mangut Innocent Amos (innocent_m)
Ebenezer Adedotun Ogunbanjo (adedotun_e)

<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px'></span>
