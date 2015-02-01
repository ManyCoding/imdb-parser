# imdb-parser
This is a simple script to read movies data (title&year) from CSV, get their rating from IMDB through OMDB API, and write down the list, sorted by rating. Parallelizing is done through Celluloid


## Dependencies

CSV

omdb https://github.com/jvanbaarsen/omdb

celluloid


## Installation
	
	Get ruby and gems if you still haven't - http://rubyinstaller.org/
	Download omdb https://github.com/jvanbaarsen/omdb

	$ gem install celluloid
	$ cd omdb_folder
	$ gem build omdb.gemspec 
	$ gem install omdb-1.0.4.gem


## Usage

	input file format - CSV file, including title, year (optional) (sample input)[https://drive.google.com/file/d/0B-mR_eT8iE68NU1JcEMycmJ4R00/view]
	output - title year -- rating

	$ ruby imdbParser.rb input.csv
	$ ruby imdbParser.rb input.csv output.txt


## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
