
class AutoMigration
	@changes = {}

	def self.compare (older, newer)
		@changes  = {}
		self.compare_instance_methods(older, newer)
		self.compare_class_methods(older, newer)
		self.compare_instance_variables(older, newer)
		return @changes
	end

	def self.compare_instance_methods (older, newer)
		diff = older.instance_methods - newer.instance_methods
		@changes[:remove_instance_method] = []
		diff.each do |method|
			@changes[:remove_instance_method].push(method)
		end
	end

	def self.compare_class_methods(older, newer)
		diff = older.methods - newer.methods
		@changes[:remove_class_method] = []
		diff.each do |method|
			@changes[:remove_class_method].push(method)
		end
	end

	def self.compare_instance_variables(older, newer)
		diff = older.instance_variables - newer.instance_variables
		@changes[:remove_instance_variable] = []
		diff.each do |variable|
			@changes[:remove_instance_variable].push(variable)
		end
	end
end