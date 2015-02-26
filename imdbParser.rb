#!/usr/bin/ruby

# program: imdbParser.rb
# usage:   ruby imdbParser.rb input.csv (output)

require 'omdb'
require 'CSV'
require 'celluloid/autostart'
Celluloid.logger = nil

class Movie
	attr_accessor :title, :year, :rating, :ratingFuture
	
	def initialize(title, year, ratingFuture)
		@title = title
		@ratingFuture = ratingFuture
		@year = year || "NO_YEAR"
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
		# 0 for unrated movies
		@rating = movie[:movie].imdb_rating == 'N/A' ? 0 : movie[:movie].imdb_rating.to_f unless movie[:status] == 404
	end
end

# check the number of arguments
unless ARGV.length == 1 || ARGV.length == 2
	puts "Wrong number of arguments."
	puts "Usage: ruby imdbParser.rb input.csv (output.txt)\n"
	exit
end

inputFile = ARGV[0]
#if null outputFile is default *_output.txt, where * is input file name
outputFile = ARGV.length == 1 ? outputFile = inputFile.chomp(File.extname(inputFile)) + "_output.txt" : ARGV[1]

# an array which holds Movies
movies = Array.new
# the number of lines in input file
lines = %x{wc -l #{inputFile}}.split.first.to_i

# loop through each record in the csv, adding them to our array
CSV.foreach(inputFile) do |row|
	rating = Rating.new
	# create future to run method asynchronously
	future = rating.future :getRatingFromImdb, row[0], row[1]
	
	#show progress
	puts "fetching data " + (($. / lines.to_f) * 100).ceil.to_s + "%" if $. % 100 == 0
	# put movie into array
	movies.push Movie.new row[0], row[1], future
	
	# try to keep the number of threads around 20
	rating.async.terminate if Thread.list.length > 20
end

begin
#get our ratings from future objects
movies.each do |m|
	m.rating = m.ratingFuture.value || -1
end
rescue
	puts "Request failed"
end

# sort data by rating
movies.sort_by! {|x| [x.rating]}.reverse!

# write down all the sorted records in the SortedOutputFile
File.open(outputFile, "wb") do |file|
	file << "#0 for unrated, -1 for unfound\n\n"
	movies.each do |m|
		file << m.title + " " + m.year.to_s + " -- " + m.rating.to_s + "\n"
		puts m.title + " " + m.year +  " -- " + m.rating.to_s + "\n"
	end
end

puts "\nprocessed #{movies.size}/#{lines} lines, check #{outputFile}"
