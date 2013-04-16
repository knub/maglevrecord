class ModuleReferenceFinder
  def find_referenced_modules_for(constant)
    @referenced_modules = Set.new
    reference(constant)
    @referenced_modules
  end

  def reference(constant)
    return if @referenced_modules.include?(constant)
    parent = constant.module_parent
    while parent != nil
      @referenced_modules.add(parent)
      parent = parent.module_parent
    end
    @referenced_modules.add(constant)

    included_modules = constant.included_modules
    submodules = constant.constants.map do |const|
        begin
          constant.const_get(const)
        rescue Exception => e; end
      end.select do |mod|
        [Module, Class].include?(mod.class)
      end
    extended_modules = (class << constant; self end).included_modules

    referenced_modules = included_modules + submodules + extended_modules
    unless referenced_modules.empty?
      referenced_modules.map do |mod|
        reference(mod)
      end
    end
  end
  private :reference
end

if __FILE__ == $0
  # EXAMPLE USAGE
  require "rubygems"
  require "rake"
  puts "Finding all module references of Rake."
  ref_finder = ModuleReferenceFinder.new
  referenced_modules = ref_finder.find_referenced_modules_for(Rake)
  puts referenced_modules.to_a.map { |mod| mod.name }.sort.inspect
end

