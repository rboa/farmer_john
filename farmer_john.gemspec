version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'farmer_john'
  s.version     = version
  s.summary     = 'some sample text'
  s.description = 'some more sample text'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.authors           = ['Bryan Powell', 'Daniel Klatt']
  s.email             = 'bryan@metabahn.com'
  s.homepage          = 'http://metabahn.com'
  
  s.files        = Dir['MIT-LICENSE', 'lib/**/*']
  s.require_path = 'lib'
end
