#!/usr/bin/ruby

# program: imdbParser.rb
# usage:   ruby imdbParser.rb InputFile SortedOutputFile

require 'omdb'
require 'CSV'
require 'celluloid/autostart'
Celluloid.logger = nil

class Movie
	attr_accessor :title, :rating, :rating_future
	
	def initialize(title, rating, rating_future)
		@title = title
		@rating = rating
		@rating_future = rating_future
	end
end

class Rating
	include Celluloid
	
	def getRatingFromImdb(title, year)
		# -1 for unfound movies
		@rating = -1
		# get movie data through OMDB API
		movie = Omdb::Api.new.fetch(title, year)
		# check if a movie was found
		if movie[:status] != 404
			# 0 for unrated movies
			@rating = movie[:movie].imdb_rating == 'N/A' ? 0 : movie[:movie].imdb_rating.to_f
		end
	end
end

# check the number of arguments
unless ARGV.length == 2
	puts "Wrong number of arguments."
	puts "Usage: ruby imdbParser.rb InputFile.csv SortedOutputFile.txt\n"
	exit
end

inputFile = ARGV[0]
outputFile = ARGV[1]

# an array which holds Movies
movies = Array.new

# loop through each record in the csv, adding them to our array
CSV.foreach(inputFile, encoding:"UTF-8") do |row|
	rating = Rating.new
	# create future to get our rating asynchronously
	future = rating.future :getRatingFromImdb, row[0], row[1]
	# create movie object
	movie = Movie.new row[0], -1 , future
	
	#show progress
	count = %x{wc -l #{inputFile}}.split.first.to_i
	if $. % 100 == 0
		puts "fetching data " + (($. / count.to_f) * 100).ceil.to_s + "%"
	end
	# put movie into array
	movies.push movie
end

movies.each do |m|
	m.rating = m.rating_future.value == nil ? -1 : m.rating_future.value
end

# sort data by rating
movies.sort! {|x,y| y.rating <=> x.rating}

# write down all the sorted records in the SortedOutputFile
File.open(outputFile, "wb") do |file|
	movies.each do |m|
		file << m.title + " -- " + m.rating.to_s + "\n"
		puts m.title + " -- " + m.rating.to_s + "\n"
	end
end

puts "done, check outputFile"