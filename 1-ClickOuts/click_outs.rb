#!/usr/bin/ruby
# Execute this function using the latest version of Ruby for maximum compatibility
# Commandline parameters
# Input file name: The name of the input file as the first parameter
# Output file name (Optional): The name of the output file as the second parameter, defaults to ClickOutData.csv

# Array to store every line of data
@line_arr = []

# Read from the specified input file as done from the commandline
# This uses regex to look for the specific GET requests
File.open(ARGV[0].to_s) { |f| @line_arr = f.grep(/GET.*\/out\/[0-9]+/i) }

# Calculates the clickouts per minute and returns a hash where the key is the time and value is the clicks
def calculate_outs_per_minute(raw_array)
	stat_h = Hash.new(0)

    raw_array.each do |x|
        time_str =  x[/\[.*?\]/] # Get the full time information as string
        time_str = time_str[1..time_str.length-2] # remove the square brackets
        mins_only_str = time_str[0..time_str.length-10] # Remove the seconds and timezone information
        stat_h[mins_only_str] += 1
    end
    return stat_h
end

# Find and returns the highest number of clicks in a minute and the minute of occurrence
def hash_max(hash)
	hash.max_by{|k,v| v}
end

# Find and returns the minimum number of clicks in a minute and the minute of ocurrence
def hash_min(hash)
	hash.min_by{|k,v| v}
end

# Find and returns the average number of clicks per minute
def hash_mean(hash)

	# Sums the total number of clicks
	total = 0
	hash.each do |key, value|
		total += value
	end

	# Return the total divided by the number of data points (minutes) which is the hash length/size
	return total.to_f/hash.length
end

# Calculates the standdard deviation of clicks per minute
def hash_stddev(hash, mean = nil)
	# If the mean is not provided, it is calculated from the hash
	mean = hash_mean(hash) if mean.nil?

	# Intermediate value of Sum(x-u)^2
	intermediate = 0.0
	hash.each do |key, value|
		intermediate += (value-mean)**2
	end

	# Find the final value by dividing by number of data points (hash length) and then square rooting everything
	final_value = Math.sqrt(intermediate.to_f/hash.length)
	return final_value
end

# Function to generate the CSV given the required data
def generate_CSV(fname, hash, mean, min, max, stddev)

	# Initialize file for csv construction
	csv_file = File.new("#{fname}.csv", "w")
	# Counter for writing to the first four lines
	counter = 1

	# Sort the hash by time first
	hash = hash.sort_by { |time, clicks| time }

	# First four lines are special as it contains the min, max, mean, stddev
	
	# Writing the first line. Contains the Time, Clicks title as well as the min clicks data
	csv_file.puts("Time, Clicks,,Min,#{min[1]},#{min[0]}")

	# Writing the rest of the data
	hash.each do |time, clicks|
		# Each line contains the time (seconds and timezone offset truncated) and clicks
		temp_line = "#{time}, #{clicks}"

		# 2nd, 3rd, and 4th line with the max, mean, and standard deviation data respectively
		temp_line += ",,Max,#{max[1]},#{max[0]}" if counter == 1
		temp_line += ",,Mean,#{mean}" if counter == 2
		temp_line += ",,Std.dev,#{stddev}" if counter == 3

		# Write to the file
		csv_file.puts(temp_line)

		# Increment counter
		counter += 1
	end

	# Close the file handle
	csv_file.close
end

# Temporary Variables to feed into generate_CSV function
min_data_hash = calculate_outs_per_minute(@line_arr)
mean = hash_mean(min_data_hash)
min = hash_min(min_data_hash)
max = hash_max(min_data_hash)
stddev = hash_stddev(min_data_hash, mean)

# Call generate CSV function
if ARGV[1].nil?
	generate_CSV("ClickOutData", min_data_hash, mean, min, max, stddev)
else
	generate_CSV(ARGV[1], min_data_hash, mean, min, max, stddev)
end
