# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "psych_shield"
  s.version     = "0.0.1"
  s.authors     = ["HD Moore"]
  s.email       = ["hdm@rapid7.com"]
  s.homepage    = ""
  s.summary     = %q{This gem provides a filter for the Psych YAML parser}
  s.description = %q{The psych_shield gem provides a configurable filter for the default Psych YAML parser in Ruby 1.9 }

  s.files         = Dir.glob('lib/**/*.rb') + [ "LICENSE" ]
  s.test_files    = Dir.glob('test/**/*.{rb,data}')
  s.require_paths = ["lib"]
end
