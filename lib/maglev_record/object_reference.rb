

class Object
  #
  # breadth first search for references from the given object to self
  #
  def reference_path_to(to_object, length, trace = false)
    paths = [[to_object]]
    traversed = IdentitySet.new
    traversed.add(to_object)
    start_size = 1 if trace
    while not paths.empty? and paths.first.size <= length
      references = paths[0][0].find_references_in_memory
      # if we print here a SecurityError mey occur
      references.each{ |reference| 
        return [reference] + paths[0] if reference.equal?(self)
        unless traversed.include?(reference) or paths.any?{ |path| reference.equal?(path)}
          paths.push([reference] + paths[0])
          traversed.add(reference)
        end
      }
      if trace and start_size != paths[0].size
        puts "reference_path_length: #{paths[0].size}"
        start_size = paths[0].size
      end
      paths.delete_at(0)
    end
    return nil
  end
  
  def __hash_key_value(anObject)
    begin
      assoc_value = instance_variable_defined?(:@_st_value)
      assoc_key = instance_variable_defined?(:@_st_key)
    rescue NameError
      return nil
    end
    return nil unless assoc_key.equal?(anObject) or assoc_value.equal?(anObject)
    return [assoc_key, assoc_value]
  end
  
  def __instance_variable_equal_to(anObject)
    return nil unless self.respond_to?(:instance_variables) and self.respond_to?(:instance_variable_get)
    self.instance_variables.each{ |v| 
      return v if self.instance_variable_get(v).equal?(anObject)
    }
    return nil
  end
  
  def __eigenclass_equal_to(anObject)
    # breaks maglev if this is used by 
    # maglev-ruby -e "require 'object_reference'; o = Object.new; start = Time.now; f = o.string_reference_path_to(true, 20); p start - Time.now; puts f"
    return false if self.class.equal?(Array)
    eigenclass = class << self
      self
    end
    puts "got it!"
    eigenclass.equal? anObject
  end

  def __incuded_module_equal_to(anObject)
    included_modules.any?{ |m| m.equal?(anObject)} if respond_to? :included_modules
  end

  # format the reference path
  #   returns a human readable string
  #
  #   length
  #     the maximum length of the path
  #
  #   width_of_line
  #     the maximum size of a line
  #
  #   trace
  #     true if reference_path_length shall be printed to stdout to trace the progress
  #     false otherwise
  #
  #   pretty
  #     true if module includes shall be detected
  #     false if maglev internals shall be revealed
  #
  def string_reference_path_to(to_object, length = 10, width_of_line = 80, trace = true, pretty = true)
    reference_path = reference_path_to(to_object, length, trace)
    return "" if reference_path.nil?
    lines = []
    left_column_size = 0
    referenced_index = 0
    while referenced_index < reference_path.size - 1
      # prepare loop
      object = reference_path[referenced_index]
      referenced = reference_path[referenced_index + 1]
      referenced_index += 1
      name_of_referenced = '?? of'
      inspect_string = nil
      # switch case on displaying references
      begin 
        puts "#obj: #{object.inspect}  #{referenced.inspect} at: #{referenced_index}\n\n"
        # object --> class
        if object.class.equal?(referenced)
          name_of_referenced = 'class of'
        # class --> superclass
        elsif object.respond_to? :superclass and object.superclass.equal?(referenced)
          name_of_referenced = 'superclass of'
        # included
        elsif pretty and object.__incuded_module_equal_to(reference_path[referenced_index + 2])
          name_of_referenced = 'included by'
          referenced = reference_path[referenced_index + 2]
          referenced_index += 2
        # OrderPreservingHashAssociation --> ...
        elsif not object.__hash_key_value(referenced).nil?
          assoc_key, assoc_value = object.__hash_key_value(referenced)
          puts "lalalalala #{assoc_key} #{assoc_value}"
          if assoc_value.equal?(referenced)
            name_of_referenced = 'value of'
          elsif assoc_key.equal?(referenced)
            name_of_referenced = 'key of'
          end
        # ... --> OrderPreservingHashAssociation
        elsif not referenced.__hash_key_value(referenced).nil?
          assoc_key, assoc_value = referenced.__hash_key_value(referenced)
          inspect_string = "#{assoc_key.inspect} => #{assoc_value.inspect}"
          name_of_referenced = 'association in'
        # ... --> attribute
        elsif not (variable = object.__instance_variable_equal_to(referenced)).nil?
          name_of_referenced = variable.to_s + ' in'
        # [...] -> object at index
        elsif object.respond_to?(:find_index) and (index = object.find_index{ |element| element.equal?(referenced)})
          name_of_referenced = "at #{index.inspect} of"
        # eigenclass
        elsif object.__eigenclass_equal_to(referenced)
          name_of_referenced = "eigenclass of"
        elsif referenced.__eigenclass_equal_to(object)
          name_of_referenced = "eigenbase of"
        end
      rescue Exception => e
        name_of_referenced = 'error'
        referenced = e
      end
      begin
        inspect_string = referenced.inspect if inspect_string.nil?
      rescue
        inspect_string = 'can not inspect this object'
      end
      lines << [name_of_referenced, inspect_string]
      left_column_size = name_of_referenced.size if name_of_referenced.size > left_column_size
    end
    width_of_line -= 8 # subtract additional characters like ' is ' ' of '
    right_column_size = width_of_line - left_column_size
    right_column_size = 10 if right_column_size < 0
    s = ""
    lines.reverse.each{ |line|
      s += "#{line[1][0..right_column_size]} is \n#{line[0].rjust(left_column_size)} "
    }
    return s + "#{reference_path[0].inspect}"
  end
end

# TestCases

## Hash
# maglev-ruby -e "require 'object_reference'; d = {a:'2', b: 34}; f = d.string_reference_path_to(d[:a], 3); puts f"

## superclass
# maglev-ruby -e "require 'object_reference'; class AA;end; class BB < AA;end; class CC < BB; end; class DD < CC; end; class EE < DD; end; puts EE.string_reference_path_to(AA, 5)"

## instance var
# maglev-ruby -e "require 'object_reference'; class AA; attr_accessor :x end; o = Object.new; aa = AA.new; aa.x = o; puts aa.string_reference_path_to(o, 3)"

## class and instvar 
# maglev-ruby -e "require 'object_reference'; class AA; attr_accessor :x end; class OO; end;o = OO.new; aa = AA.new; aa.x = o; bb = AA.new; bb.x = aa; cc = AA.new; cc.x = bb; puts cc.string_reference_path_to(OO, 5)"

## Object.new references true
# maglev-ruby -e "require 'object_reference'; o = Object.new; start = Time.now; f = o.string_reference_path_to(true, 20); p start - Time.now; puts f" 

## Array
# maglev-ruby -e "require 'object_reference'; a = b = []; 20.times{a = [a]}; start = Time.now; f = a.string_reference_path_to(b, 20); p start - Time.now; puts f"

## Eigenclass (x is eigenclass of y)
# maglev-ruby -e "require 'object_reference'; class X;end; x = class <<X;self;end; puts X.string_reference_path_to(x, 5)"

## Eigenbase ( reverse of eigenclass)
# maglev-ruby -e "require 'object_reference'; class X;end; x = class <<X;self;end; puts x.string_reference_path_to(X, 5)"
