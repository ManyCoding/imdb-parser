#Encoding
#Speed
#Correct data structures
#Different name, e.g. arthur rubinstein - the love of life/ imdb - Love of Life

class IMDBparser
	def initialize(fileName)
		@fileName = fileName
		@movies = Array.new
	end

	# read CSV
	def parseCSV
		require 'CSV'
		CSV.foreach(@fileName, encoding:"UTF-8") do |row|
			@movies.push sendRequest(row[0], row[1])
		end
	end

	# get rating through OMDB API
	def sendRequest(title, year)
		require 'omdb'
		movie = Omdb::Api.new.fetch(title, year)
		#count = 0
		if movie[:status] != 404
			movie[:movie].imdb_rating + " " + title

		end
	end

	def getResults
		@movies.sort! {|x,y| y <=> x}
		File.open('results.txt', "wb") { |file| file.write(@movies)}
		puts "results.txt updated"
		#@movies.each {|movie| puts movie}
	end
end	

parser = IMDBparser.new("moviesTest.csv")
parser.parseCSV
parser.getResults