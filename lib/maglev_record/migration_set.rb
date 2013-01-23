require "set"

class Set

  # remove a random element from the set and return it
  def pop
    each { |element|
      delete element
      return element
    }
  end
end

module MaglevRecord

  #
  # A migration set defines some operations on a set of migrations
  # 
  # circles can be deteced, migrations can be clustered
  # one can expand migrations to their roots 
  # or find out migrations without children or parents
  #
  class MigrationSet
    include ::Enumerable

    class CircularMigrationOrderError < Exception
    end

    def initialize(migrations = Set.new)
      @migrations = Set.new(migrations)
    end

    def migrations
      Set.new(@migrations)
    end

    def expand!(children = true)
      todo = migrations
      while not todo.empty?
        migration = todo.pop
        add migration
        to_expand = migration.parents
        to_expand += migration.children if children
        to_expand.each{ |migration|
          todo.add(migration) unless include? migration
        }
      end
      self
    end

    def expand_parents!
      expand!(children = false)
    end

    def copy
      self.class.new(self)
    end

    def expanded
      self.copy.expand!
    end

    def expanded_parents
      self.copy.expand_parents!
    end

    alias :dup :copy

    #
    # migrations in order of do and undo
    #
    def migration_sequence
      raise CircularMigrationOrderError, 'list has circle of migrations' if has_circle?
      # use tsort? 
      # http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tsort/rdoc/TSort.html
      todo = tails.to_a
      result = []
      while not todo.empty?
        todo.sort!
        migration_to_expand = todo.delete_at(0)
        result << migration_to_expand
        migration_to_expand.children.each{ |child|
          todo << child unless (todo.include? child or !include? child)
          result.delete(child)
        }
      end
      result
    end

    def migrations_by_time
      migrations.to_a.sort
    end

    def heads
      Set.new(migrations.select{ |migration| 
        migration.children.all?{ |child|
            ! include?(child)
          }
        })
    end

    # return a set of migrations without parent
    def tails
      Set.new(migrations.select{ |migration| 
        migration.parents.all?{ |parent|
            ! include?(parent)
          }
        })
    end

    def has_circle?
      not circles.empty?
    end

    def clusters
      s = migrations
      clusters = Set.new
      while not s.empty?
        todo = Set.new([s.pop])
        cluster = Set.new
        while not todo.empty?
          m = todo.pop
          s.delete(m)
          cluster.add(m)
          (m.parents + m.children).select{ |migration|
            s.include? migration
          }.each{ |migration|
            todo.add(migration)
          }
        end
        clusters.add(cluster.to_a.sort)
      end
      clusters
    end

    def circles
      circles = Set.new
      clusters.each{ |cluster| 
        while not cluster.empty?
          leaf_found = cluster.any?{ |migration|
            no_parents = !migration.parents.any?{|parent| cluster.include? parent}
            no_children = !migration.children.any?{|child| cluster.include? child}
            leaf_found = (no_children or no_parents)
            if leaf_found
              cluster.delete(migration)
            end
            leaf_found
          }
          break if not leaf_found
        end
        circles.add(cluster) unless cluster.empty?
      }
      circles
    end

    def add(migration)
      @migrations.add(migration)
    end

    alias :<< :add

    def include?(migration)
      @migrations.include?(migration)
    end

    def empty?
      @migrations.empty?
    end

    def each
      raise ArgumentError, 'I need a block argument for iteration ' unless block_given?
      migrations.each{ |migration| yield migration}
    end
  end
end
