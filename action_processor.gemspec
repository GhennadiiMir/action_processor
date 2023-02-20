Gem::Specification.new do |s|
  s.name        = 'action_processor'
  s.version     = '0.0.1'
  s.required_ruby_version = '>= 3'
  s.date        = '2023-02-20'
  s.summary     = "Group each of your complex multy-model manipulations in dedicated ActionProcessor"
  s.description = "action_processor"
  s.authors     = ["Ghennadii Mirosnicenco", "Pavel Mirosnicenco"]
  s.email       = 'linkator7@gmail.com'
  s.files       = ["lib/action_processor.rb"]
  s.homepage    =
    'https://rubygems.org/gems/action_processor'
  s.license       = 'MIT'
  s.add_dependency "active_support", "~> 7.0.0"
  s.add_dependency "activemodel", "~> 7.0.0"
end
