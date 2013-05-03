class MaglevSupport::SubmoduleFinder
  def submodules_for(*constants)
    whole_set = Set.new
    constants.each do |constant|
      @referenced_modules = Set.new
      reference(constant)
      whole_set = whole_set.union(@referenced_modules.select do |mod|
        mod.name.to_s.include?(constant.to_s)
      end)
    end
    constants + whole_set.to_a.sort_by do |mod| mod.name end
  end

  def reference(constant)
    return if @referenced_modules.include?(constant)
    @referenced_modules.add(constant)

    submodules = constant.constants.map do |const|
      begin
        constant.const_get(const)
      rescue Exception => e; end
    end.select do |mod|
      # We only want constants which are classes or modules, e.g. no Fixnums, Strings, ...
      [Module, Class].include?(mod.class)
    end

    submodules.each do |mod|
      reference(mod)
    end
  end
  private :reference
end

if __FILE__ == $0
  # EXAMPLE USAGE
  require "rubygems"
  require "rake"
  puts "Finding all submodules of Rake."
  ref_finder = SubmoduleFinder.new
  referenced_modules = ref_finder.submodules_for(Rake)
  puts referenced_modules.to_a.map { |mod| mod.name }.sort.inspect
end
