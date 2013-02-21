

class Object
  #
  # breadth first search for references from the given object to self
  #
  def reference_path_to(to_object, length)
    paths = [[to_object]]
    while not paths.empty? and paths.first.size <= length
      references = paths[0][0].find_references_in_memory
      # if we print here a SecurityError mey occur
      references.each{ |reference| 
        return [reference] + paths[0] if reference.equal?(self)
        unless paths.any?{ |path| reference.equal?(path)} or paths[0].any?{ |object| reference.equal?(object)}
          paths.push([reference] + paths[0])
        end
      }
      paths.delete_at(0)
    end
    return nil
  end
  
  def __hash_key_value
    begin
      assoc_value = instance_variable_defined?(:@_st_value)
      assoc_key = instance_variable_defined?(:@_st_key)
    rescue NameError
      return nil
    end
    return nil unless assoc_key and assoc_value
    return [assoc_key, assoc_value]
  end
  
  def readable_reference_path_to(to_object, length, width_of_line = 80)
    reference_path = reference_path_to(to_object, length)
    return "" if reference_path.nil?
    lines = [["", reference_path[0]]]
    left_column_size = 0
    reference_path.inject{ |object, _referenced|
      referenced = _referenced
      name_of_referenced = '??'
      if object.respond_to? :superclass and object.superclass.equal?(referenced)
        name_of_referenced = 'superclass'
      elsif not object.__hash_key_value.nil?
        # OrderPreservingHashAssociation
        assoc_key, assoc_value = object.__hash_key_value
        if assoc_value.equal?(referenced)
          name_of_referenced = 'value'
        elsif assoc_key.equal?(referenced)
          name_of_referenced = 'key'
        end
      elsif not referenced.__hash_key_value.nil?
        # OrderPreservingHashAssociation
        assoc_key, assoc_value = referenced.__hash_key_value
        referenced = {assoc_key => assoc_value}
        name_of_referenced = 'assoc'
      end
      lines << [name_of_referenced, referenced]
      left_column_size = name_of_referenced.size if name_of_referenced.size > left_column_size
      _referenced # referenced is next object
    }
    left_column_size += 2
    right_column_size = width_of_line - left_column_size
    right_column_size = 10 if right_column_size < 0
    s = ""
    lines.each{ |line|
      begin
        inspectString = line[1].inspect
      rescue
        inspectString = 'can not inspect this object'
      end
      s += "#{line[0].ljust(left_column_size)}#{inspectString[0..right_column_size]}\n"
    }
    return s
  end
end
