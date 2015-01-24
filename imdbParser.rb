#!/usr/bin/ruby

# program: imdbParser.rb
# usage:   ruby imdbParser.rb input.csv output

require 'omdb'
require 'CSV'
require 'celluloid/autostart'
Celluloid.logger = nil

class Movie
	attr_accessor :title, :rating, :ratingFuture
	
	def initialize(title, ratingFuture)
		@title = title
		@ratingFuture = ratingFuture
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
	# create future to run method asynchronously
	future = rating.future :getRatingFromImdb, row[0], row[1]
	
	#show progress
	count = %x{wc -l #{inputFile}}.split.first.to_i
	if $. % 100 == 0
		puts "fetching data " + (($. / count.to_f) * 100).ceil.to_s + "%"
	end
	# put movie into array
	movies.push Movie.new row[0] , future
	
	# try to keep the number of threads around 20
	if Thread.list.length > 20
		rating.async.terminate
	end
end

#get our ratings from future objects
movies.each do |m|
	m.rating = m.ratingFuture.value == nil ? -1 : m.ratingFuture.value
end

# sort data by rating
movies.sort_by! {|x| [x.rating]}.reverse!

# write down all the sorted records in the SortedOutputFile
File.open(outputFile, "wb") do |file|
	file << "#0 for unrated, -1 for unfound\n\n"
	movies.each do |m|
		file << m.title + " -- " + m.rating.to_s + "\n"
		puts m.title + "\t"+ m.rating.to_s + "\n"
	end
end

puts "done, check output"
