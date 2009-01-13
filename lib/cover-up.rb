module CoverUp
  # This tracks overall coverage results for a run
  class Result
    attr_accessor :files

    # This initializes the result with the individual file results
    def initialize(files)
      self.files = files
    end
    
    # This returns the total amount of lines in this coverage report
    def lines
      sum = 0
      self.files.collect { |f| f.lines }.each { |i| sum += i }
      sum
    end
    
    # This returns the total amount of lines without exclusions in this coverage report
    def lines_without_exclusions
      sum = 0
      self.files.collect { |f| f.lines_without_exclusions }.each { |i| sum += i }
      sum
    end
    
    # This calculates the overall hit percentage for the run
    def hit_percentage
      return 0 if self.lines_without_exclusions.to_f == 0.0
      hit = self.files.collect { |f| f.hit }.flatten
      (hit.length.to_f / self.lines_without_exclusions.to_f) * 100.0
    end
    
    # This calculates the overall miss percentage for the run
    def missed_percentage
      return 0 if self.lines_without_exclusions.to_f == 0.0
      missed = self.files.collect { |f| f.missed }.flatten
      (missed.length.to_f / self.lines_without_exclusions.to_f) * 100.0
    end
  end

  # This tracks coverage results for an individual file
  class FileResult
    attr_accessor :name, :lines, :hit, :missed, :excluded

    # This initializes the file result with the amount of lines, and the hit/missed/excluded lines for the file, along with the name
    def initialize(name, lines, hit, missed, excluded)
      self.name = name
      self.lines = lines
      self.hit = hit
      self.missed = missed
      self.excluded = excluded
    end
    
    # This returns the amount of lines after the excluded lines have been removed
    def lines_without_exclusions
      self.lines - excluded.length
    end
    
    # This calculates the percentage of lines that were hit by the code being covered
    def hit_percentage
      return 0 if self.lines_with_exclusions.to_f == 0.0
      (self.hit.length.to_f / self.lines_with_exclusions.to_f) * 100.0
    end
    
    # This calculates the percentage of lines that were missed by the code being covered
    def missed_percentage
      return 0 if self.lines_with_exclusions.to_f == 0.0
      (self.missed.length.to_f / self.lines_with_exclusions.to_f) * 100.0
    end
  end
end

# This is the wrapper call that is used to run code coverage on Ruby code
def coverage(options = {}, &block)
  # We default the coverage scan to any Ruby files in the current directory, but that can be over-ridden
  files = options[:include].nil? ? Dir.glob("*.rb") : Dir.glob(options[:include])
  # This will hold the trace information
  trace = {}
  # Let's set a trace function so that every method call can be tracked
  set_trace_func(proc do |event, file, line, id, binding, klass|
    # We unify the filename to it's absolute path
    file = File.expand_path(file)
    # Add the line number that was hit for this file, if it hasn't already been hit
    trace[file] ||= []
    trace[file] << line unless trace[file].include?(line)
  end)
  # Now that we've set up the trace function, we can execute the code (trapping any exceptions)
  begin
    yield
  rescue Exception => ex
    puts "ERROR: exception \"#{ex.message}\" while running code coverage"
  end
  # Once that's run, we stop the trace function
  set_trace_func(nil)
  # Now we collate the results
  results = []
  # Loop through all files
  files.each do |file|
    # Expand the path, to unify it as we did before
    file = File.expand_path(file)
    # Grab the file data
    data = File.read(file)
    # Grab the amount of lines for the file
    lines = data.split("\n")
    # Keep track of which lines are hit, missed or excluded
    hit = []
    missed = []
    excluded = []
    # Loop through and analyse lines
    lines.each_with_index do |line, index|
      number = index + 1
      # If the line is a comment or an empty line, or it's the last line and it's "end", it's excluded
      if line.strip[0...1] == "#" || line.strip.empty? || (number == lines.length && line.strip == "end")
        excluded << number
      elsif (trace[file] || []).include?(number)
        # Otherwise, if it was in the trace, it was hit
        hit << number
      else
        # Lastly, if it isn't excluded or hit, it was missed
        missed << number
      end
    end
    # Create the file result with the file name, the total lines, the lines hit, the lines that weren't hit, and the lines that were excluded
    results << CoverUp::FileResult.new(file, lines.length, hit, missed, excluded)
  end
  # Return the coverage results
  CoverUp::Result.new(results)
end