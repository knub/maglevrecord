require 'logger'

module MaglevRecordTransient
  # Logger.maglev_persistable
  # Logger::Formatter.maglev_persistable
  # Logger::LogDevice.maglev_persistable
  log = Logger.new(STDOUT)
  log.level = Logger::INFO
  log.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
  end
  Logger = log
  # Maglev.commit_transaction
end
