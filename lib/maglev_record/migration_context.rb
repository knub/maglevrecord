

module MaglevRecord

  #
  # Migrations are loaded in MigrationContexts
  # The migration context defines methods that can be used to migrate
  #
  class MigrationContext

    #
    # Timestamp is the timestamp for migrations
    #
    class Timestamp

      class BadTimeFormat < ArgumentError
      end

      include ::Comparable

      def initialize(string)
        @string = string.dup
        parse_string
        @timestamp = get_timestamp
      end

      def <=>(other)
        timestamp <=> other.timestamp
      end

      #
      # to_time looses the milliseconds
      #
      def to_time
        Time.utc(@year, @month, @day, @hour, @minute, @second) + @houroffset
      end

      def year
        to_time.year
      end

      def month
        to_time.month
      end

      def day
        to_time.day
      end

      def hour
        to_time.hour
      end

      def minute
        to_time.min
      end

      def second
        to_time.sec
      end

      attr_reader :timestamp, :millisecond, :microsecond

      def get_timestamp
        t = year
        t = month + t * 100
        t = day + t * 100
        t = hour + t * 100
        t = minute + t * 100
        t = second + t * 100
        t = millisecond + t * 1000
        t = microsecond + t * 1000
        return t
      end

      def parse_string
        data = /(\d?\d\d\d\d)-(\d?\d)-(\d?\d) (\d?\d):(\d?\d):(\d?\d) ((\d?\d?\d)ms )?((\+|\-)\d\d)\:00/.match(@string).to_a
        raise BadTimeFormat, "invalid string #{@string.inspect} must be like \"yyyy-mm-dd hh:mm:ss +hh:00\" or \"yyyy-mm-dd hh:mm:ss xxxms +hh:00\"" if data.empty?
        # 0 whole data
        @year = data.at(1).to_i
        @month = data.at(2).to_i
        @day = data.at(3).to_i
        @hour = data.at(4).to_i
        @minute = data.at(5).to_i
        @second = data.at(6).to_i
        @millisecond = data.at(7).to_i
        @microsecond = 0
        @houroffset = data.at(9).to_i * 60 * 60 # hours * minutes/hour * seconds/minute
        # data.at(9).to_i # + -
      end

      def to_s
        @string
      end

      def self.parse(string)
        self.new(string)
      end

      def hash
        timestamp.hash
      end

    end

    def initialize(migration_factory)
      @migration_factory = migration_factory
    end

    def load_string(source, file = __FILE__)
      @source = source
      value = instance_eval source, file
      @source = nil
      value
    end

    attr_reader :source

    def load_file(file_path)
      raise ArgumentError, "file #{file_path.inspect} not found" unless File.file?(file_path)
      load_string(File.open(file_path).read)
    end

    def load_directory(directory_path)
      Dir.foreach(directory_path){ |file_name|
        load_file(directory_path + '/' + file_name) if file_name.end_with? '.rb'
      }
    end

    def migration(timestamp_string)
      _timestamp = timestamp(timestamp_string)
      migration = @migration_factory.migration(_timestamp)
      migration.source = source
      migration
    end

    def first_migration
      @migration_factory.first_migration
    end

    def timestamp(string)
      Timestamp.parse(string)
    end
  end
end
