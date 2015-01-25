# imdb-parser
This is a simple script to read movies data (title&year) from CSV, get their rating from IMDB through OMDB API, and write down the list, sorted by rating. Parallelizing is done through Celluloid


## Dependencies

CSV

omdb https://github.com/ManyCoding/omdb fork from https://github.com/jvanbaarsen/omdb

celluloid


## Installation

	$ gem install celluloid
	download omdb with rating, go in the folder
	$ gem build omdb.gemspec 
	$ gem install omdb


## Usage

	input file format - comma separated CSV, e.g. title, year (optional)
	output - title -- rating

	$ ruby imdbParser.rb input.csv
	$ ruby imdbParser.rb input.csv output.txt


## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
