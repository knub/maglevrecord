require "logger"

module MaglevRecord
  log = Logger.new(STDOUT)
  log.level = ::Logger::INFO
  log.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
  end
  Logger = log
end
