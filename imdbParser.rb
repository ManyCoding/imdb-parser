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

class Movie <
	Struct.new(:title, :year, :rating)
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
require 'CSV'

file = CSV.foreach(inputFile, encoding:"UTF-8") do |row|
	m = Movie.new
	m.title = row[0]
	m.year = row[1]
	# in case we didn't find the rating
	m.rating = -1
	# get movie data through OMDB API
	movie = Omdb::Api.new.fetch(m.title, m.year)
	
	#show progress
	count = %x{wc -l #{inputFile}}.split.first.to_i
	if $. % 50 == 0
		puts "fetching data " + (($. / count.to_f) * 100).ceil.to_s + "%"
	end
	# check af a movie is found
	if movie[:status] != 404
		m.rating = movie[:movie].imdb_rating == 'N/A' ? 0 : movie[:movie].imdb_rating.to_f
	end
	movies.push m
end

# sort the data by rating
movies.sort! {|x,y| y.rating <=> x.rating}

# write down all the sorted records in the SortedOutputFile
File.open(outputFile, "wb") do |file|
	movies.each do |m|
		file << m.title + " -- " + m.rating.to_s + "\n"
	end
end

puts "outputFile is updated"