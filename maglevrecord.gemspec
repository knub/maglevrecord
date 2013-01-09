Gem::Specification.new do |s|
  s.name        = 'maglevrecord'
  s.version     = '0.0.2'
  s.date        = '2013-01-08'
  s.summary     = "MagLev persistence with an ActiveRecord-like interface! Atleast that's the plan."
  s.description = "This is a very early prototype and not intended for use."
  s.authors     = ["Dimitri Korsch", "Kirstin Heidler", "Nicco Kunzmann", "Matthias Springer", "Stefan Bunk"]
  s.files       = Dir["{bin,lib,man,test,spec}/**/*"]
  s.email       = "stefan.bunk@studentx.hpi.uni-potsdam.de"
  s.homepage    = 'https://github.com/knub/maglevrecord'

  s.add_development_dependency('bacon')
end
