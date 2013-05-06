require File.expand_path "lib/maglev_record/maglev_record"

Gem::Specification.new do |s|
  s.name         = 'maglevrecord'
  s.version      = MaglevRecord::VERSION
  s.date         = '2013-03-10'
  s.summary      = "MagLev persistence with an ActiveRecord-like interface!"
  s.description  = "Library for using to MagLev to persist your data in a Rails app."
  s.authors      = ["Dimitri Korsch", "Kirstin Heidler", "Nicco Kunzmann", "Matthias Springer", "Stefan Bunk"]
  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.email        = "bp2012h1@hpi.uni-potsdam.de"
  s.homepage     = 'https://github.com/knub/maglevrecord'
  s.require_path = 'lib'

end
