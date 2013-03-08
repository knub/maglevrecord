require "logger"

module MaglevRecord
  # nil.pause
  Logger.maglev_persistable
  # Maglev.commit_transaction
  log = Logger.new(STDOUT)
  log.level = ::Logger::INFO
  log.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
  end
  Logger = log
end
