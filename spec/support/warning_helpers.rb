module WarningHelpers
  def capture_warnings
    StringIO.open("") do |stderr|
      stderr, $stderr = $stderr, stderr
      yield
      stderr, $stderr = $stderr, stderr
      stderr.string
    end
  end
end
