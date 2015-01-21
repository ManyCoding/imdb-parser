def parseFile(fileName, hash)
	counter = 1
	file = File.new(fileName, "r")
	key = counter
	while (line = file.gets)
		key = line
		hash[key] = counter
		counter = counter + 1
	end
	file.close
rescue => err
	puts "Exception: #{err}"
	err
end

def sendRequest
	require 'omdb'
 
	# Search for all movies with a name like 'Broken City'
	movies = Omdb::Api.new.search('Broken city')
	puts movies[:status] # => 200
	puts movies[:movies].size # => 3
end

def showResults(hash)
	hash.each {|key, value| puts "#{key}: #{value}"}
end

begin
	fileName = "movies.csv"
	movies = Hash.new
	parseFile fileName, movies
	sendRequest
	#showResults movies
end
