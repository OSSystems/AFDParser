$:.push File.expand_path("../lib", __FILE__)
require "afd_parser/version"

Gem::Specification.new do |gem|
  gem.name        = "afd_parser"
  gem.version     = AfdParser::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["O.S. Systems Softwares Ltda."]
  gem.email       = "contato@ossystems.com.br"
  gem.homepage    = "http://www.ossystems.com.br/"
  gem.summary     = "Gem to parse AFDs from REPs"
  gem.description = "Use this gem to verify and parse data files generated from REPs."

  gem.files         = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
  gem.test_files    = Dir['{test}/**/*']
  gem.require_paths = ["lib"]

  gem.add_dependency('rake', '>= 0.8.7')
end
