require 'benchmark'
@line_arr = []

# Read from the file
File.open('RetailMeNotChallenge.txt') {
    |f|
    @line_arr = f.grep(/GET.*\/out\/[0-9]+/i)
}

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

def hash_max(hash)
	hash.max_by{|k,v| v}
end

def hash_min(hash)
	hash.min_by{|k,v| v}
end

def hash_mean(hash)
	total = 0
	hash.each do |key, value|
		total += value
	end

	return total.to_f/hash.length
end

def hash_stddev(hash, mean = nil)
	mean = hash_mean(hash) if mean.nil?

	intermediate = 0.0
	hash.each do |key, value|
		intermediate += (value-mean)**2
	end

	final_value = Math.sqrt(intermediate.to_f/hash.length)
	return final_value
end

test_h = calculate_outs_per_minute(@line_arr)

puts "Click outs per minute data:"
test_h.each do |hash, value|
	puts "Time: #{hash}\tClicks: #{value}"
end

mean = hash_mean(test_h)
puts "Mean: #{mean}"

max = hash_max(test_h)
puts "Max: #{max[1]} at #{max[0]}"

min = hash_min(test_h)
puts "Min: #{min[1]} at #{min[0]}"

stddev = hash_stddev(test_h, mean)
puts "Stddev: #{stddev}"
