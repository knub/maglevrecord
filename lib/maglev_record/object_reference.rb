

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
  end
end
