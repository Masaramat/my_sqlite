require "my_sqlite_request"

# equest = MySqliteRequest.new
# request = request.from('nba_player_data.csv')
# request = request.select('name')
# request.run

# request = MySqliteRequest.new
# request = request.from('nba_player_data.csv')
# request = request.select('name')
# request = request.where('college', 'University of California')
# request.run

request = MySqliteRequest.new
request = request.from('nba_player_data.csv')
request = request.select('name')
request = request.where('college', 'University of California')
request = request.where('year_start', '1997')
request.run

# request = MySqliteRequest.new
# request = request.insert('nba_player_data.csv')
# request = request.values('name' => 'Alaa Abdelnaby', 'year_start' => '1991', 'year_end' => '1995', 'position' => 'F-C', 'height' => '6-10', 'weight' => '240', 'birth_date' => "June 24, 1968", 'college' => 'Duke University')
# request.run

# request = MySqliteRequest.new
# request = request.update('nba_player_data.csv')
# request = request.values('name' => 'Alaa Renamed')
# request = request.where('name', 'Alaa Abdelnaby')
# request.run

# request = MySqliteRequest.new
# request = request.delete()
# request = request.from('nba_player_data.csv')
# request = request.where('name', 'Alaa Abdelnaby')
# request.run

# SELECT * FROM studentss

# SELECT name,email FROM students WHERE name = 'Mila'

# INSERT INTO students VALUES (John,john@johndoe.com,A,https://blog.johndoe.com)

UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Mila'

DELETE FROM students WHERE name = 'John'

