Gem::Specification.new do |s|
  s.name = "action_processor"
  s.version = "0.0.8"
  s.required_ruby_version = ">= 3"
  s.summary = "Group each of your complex multy-model manipulations in dedicated ActionProcessor"
  s.description = "action_processor"
  s.authors = ["Ghennadii Mirosnicenco", "Pavel Mirosnicenco"]
  s.email = "linkator7@gmail.com"
  s.files = ["lib/action_processor.rb",
    "lib/action_processor/errors.rb",
    "lib/action_processor/base.rb"]
  s.homepage = "https://github.com/GhennadiiMir/action_processor"
  s.license = "MIT"
  s.add_dependency "activesupport", ">= 7"
  s.add_dependency "activerecord", ">= 7"
end
