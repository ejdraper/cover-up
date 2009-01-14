require File.join(File.dirname(__FILE__), "test_helper")

class CoverageTests < Test::Unit::TestCase
  # This tests the coverage of the test code file, simply when requiring it
  def test_coverage_on_require
    results = coverage(:include => test_filename) do
      load test_filename
    end
    
    file = results.files.first
    assert_equal 16, file.lines
    assert_equal 4, file.hit.length
    assert_equal 6, file.missed.length
    assert_equal 6, file.excluded.length
    assert_equal 40, file.hit_percentage.to_i
    assert_equal 60, file.missed_percentage.to_i
    
    assert_equal 10, results.lines_without_exclusions
    assert_equal 16, results.lines
    assert_equal 40, results.hit_percentage.to_i
    assert_equal 60, results.missed_percentage.to_i
  end
  
  # This tests the coverage of the test code file, simply when instantiating an instance of the test class
  def test_coverage_on_instance
    results = coverage(:include => test_filename) do
      load test_filename
      tester = TestCode.new
    end
    
    file = results.files.first
    assert_equal 16, file.lines
    assert_equal 4, file.hit.length
    assert_equal 6, file.missed.length
    assert_equal 6, file.excluded.length
    assert_equal 40, file.hit_percentage.to_i
    assert_equal 60, file.missed_percentage.to_i
    
    assert_equal 10, results.lines_without_exclusions
    assert_equal 16, results.lines
    assert_equal 40, results.hit_percentage.to_i
    assert_equal 60, results.missed_percentage.to_i
  end
  
  # This tests the coverage of the test code file, when executing one of it's methods
  def test_coverage_on_one_method
    results = coverage(:include => test_filename) do
      load test_filename
      tester = TestCode.new
      tester.test_method1
    end

    file = results.files.first
    assert_equal 16, file.lines
    assert_equal 6, file.hit.length
    assert_equal 4, file.missed.length
    assert_equal 6, file.excluded.length
    assert_equal 60, file.hit_percentage.to_i
    assert_equal 40, file.missed_percentage.to_i

    assert_equal 10, results.lines_without_exclusions
    assert_equal 16, results.lines
    assert_equal 60, results.hit_percentage.to_i
    assert_equal 40, results.missed_percentage.to_i
  end

  # This tests the coverage of the test code file, when executing two of it's methods
  def test_coverage_on_two_methods
    results = coverage(:include => test_filename) do
      load test_filename
      tester = TestCode.new
      tester.test_method1
      tester.test_method2
    end

    file = results.files.first
    assert_equal 16, file.lines
    assert_equal 8, file.hit.length
    assert_equal 2, file.missed.length
    assert_equal 6, file.excluded.length
    assert_equal 80, file.hit_percentage.to_i
    assert_equal 20, file.missed_percentage.to_i

    assert_equal 10, results.lines_without_exclusions
    assert_equal 16, results.lines
    assert_equal 80, results.hit_percentage.to_i
    assert_equal 20, results.missed_percentage.to_i
  end
  
  # This tests the coverage of the test code file, when executing three of it's methods
  def test_coverage_on_three_methods
    results = coverage(:include => test_filename) do
      load test_filename
      tester = TestCode.new
      tester.test_method1
      tester.test_method2
      tester.test_method3
    end

    file = results.files.first
    assert_equal 16, file.lines
    assert_equal 10, file.hit.length
    assert_equal 0, file.missed.length
    assert_equal 6, file.excluded.length
    assert_equal 100, file.hit_percentage.to_i
    assert_equal 0, file.missed_percentage.to_i

    assert_equal 10, results.lines_without_exclusions
    assert_equal 16, results.lines
    assert_equal 100, results.hit_percentage.to_i
    assert_equal 0, results.missed_percentage.to_i
  end
  
  # This tests the logger option available in CoverUp to log the tracing function
  def test_logger
    files = {}
    klasses = []
    logger = Proc.new do |event, file, line, id, binding, klass|
      file = File.expand_path(file)
      files[file] ||= []
      files[file] << line
      files[file].uniq!
      klasses << klass
    end
    coverage(:include => test_filename, :logger => logger) do
      load test_filename
    end
    
    assert_equal 3, files.length
    assert_equal "coverage_tests.rb", File.basename(files.keys[0])
    assert_equal 4, files[files.keys[0]].length
    assert_equal "test_code.rb", File.basename(files.keys[1])
    assert_equal 4, files[files.keys[1]].length
    assert_equal "cover-up.rb", File.basename(files.keys[2])
    assert_equal 3, files[files.keys[2]].length
  end

  private
    def load_test_file
      load test_filename
    end
    
    def test_filename
      File.join(File.dirname(__FILE__), "test_code.rb")
    end
end