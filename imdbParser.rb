#!/usr/bin/ruby

# program: imdbParser.rb
# usage:   ruby imdbParser.rb InputFile, SortedOutputFile

#TODO
# Convention (var names)
# movies -- rating
# speed

#Encoding
#Speed
#Correct data structures
#Different name, e.g. arthur rubinstein - the love of life/ imdb - Love of Life
#How to sort if same rating

require 'omdb'
require 'CSV'
require 'celluloid/autostart'

class Movie 	
	include Celluloid
	attr_accessor :title, :year, :rating
	
	def initialize(title, year)
		@title = title
		@year = year
		# -1 for movies without rating
		@rating = -1
	end
	
	def getRatingFromImdb
		# get movie data through OMDB API
		movie = Omdb::Api.new.fetch(@title, @year)
		# check af a movie is found
		if movie[:status] != 404
			@rating = movie[:movie].imdb_rating == 'N/A' ? 0 : movie[:movie].imdb_rating.to_f
		end
	end	
end


# check the number of arguments
unless ARGV.length == 2
	puts "Wrong number of arguments."
	puts "Usage: ruby imdbParser.rb InputFile.csv, SortedOutputFile.txt\n"
	exit
end

inputFile = ARGV[0]
outputFile = ARGV[1]

# an array which holds Movies
movies = Array.new

# loop through each record in the csv, adding them to our array
CSV.foreach(inputFile, encoding:"UTF-8") do |row|
	movie = Movie.new row[0], row[1]

	#show progress
	count = %x{wc -l #{inputFile}}.split.first.to_i
	if $. % 25 == 0
		puts "fetching data " + (($. / count.to_f) * 100).ceil.to_s + "%"
	end
	# getting info through OMDB Api asynchronously
	movie.async.getRatingFromImdb
	movies.push movie
end

# sort the data by rating
movies.sort! {|x,y| y.rating <=> x.rating}

# write down all the sorted records in the SortedOutputFile
File.open(outputFile, "wb") do |file|
	movies.each do |m|
		file << m.title + " -- " + m.rating.to_s + "\n"
		#file << m.rating.to_s
	end
end

puts "outputFile is updated"