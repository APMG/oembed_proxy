require 'pathname'

module FixtureLoader
  def fixture(path)
    Pathname.new('spec/fixtures').join(path).read
  end
end
