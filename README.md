MagLevRecord - a model interface for Rails
===========================================

This is intended to replace ActiveRecord::Base when using MagLev. It is not ready for any use so far.

Installation
------------

You can install this gem from rubygems.org:
```gem install maglevrecord```


Basic persistence
-----------------

MagLevRecord classes have to include ```MaglevRecord::Base```.

```ruby
require 'maglev_record'

class Book
  include MaglevRecord::Base
  
  attr_accessor :author, :title, :comments
end
```

Newly created models and changed models must be saved explicitly. **Be sure to always call ```save``` or ```reset!``` after a model was changed!** Otherwise committing the transaction into the stone will fail at the end of the request.
```ruby
book = Book.new(:title => "A new book", :author => "The writer")
book.save
```

Model classes implement ```Enumerable```. You can use these methods for queries. Dynamic finders and indexes will be implemented later.
```ruby
book = Book.find { |b| b.author == "The writer" }
```

Delete model classes with ```book.delete```.

Validation and model reseting
-----------------------------

MaglevRecord supports model validation via ActiveModel.

```ruby
require 'maglev_record'

class Book
  include MaglevRecord::Base
  
  validates :author, :presence => true
  validates :title,  :presence => true,
                     :length => { :minimum => 5 }

  attr_accessor :author, :title, :comments
end
```

With ```book.valid?``` you can determine if a model is valid. Models are automatically validated before ```save``` and have to be valid. Validation can be skipped with ```save(:validate => false)```.

Attributes with ```attr_accessor``` can be reset if they were changed with the standard setter (```attribute=(value)```). To reset a single attribute call ```attribute_reset!```, to reset the whole model call ```reset!```. 
```ruby
book = Book.find { |b| b.author == "The writer" }
book.author = "Another author"
book.reset_author!
```
