# MagLevRecord - a model interface for Rails

This is intended to replace ActiveRecord::Base when using MagLev. It is not ready for production use, but feel free to play around with it.

## Installation

You can install this gem from rubygems.org:
```gem install maglevrecord```


## Basic Usage

### Creating classes

Classes which you wish to persist have to include ```MaglevRecord::Base``` or ```MaglevRecord::RootedBase```. You can still inherit from whatever base class you want.

```ruby
require 'maglev_record'

class Book
  include MaglevRecord::RootedBase
  
  attr_accessor :author, :title, :comments
end
```
Use attr_reader, attr_writer or attr_accessor to define your fields and use the generated getters and setters to access them. Do not access the instance variables directly, because we might need to do some background work when accessing and setting in future versions.

### Saving

There is a significant difference between ActiveRecord and MaglevRecord: ActiveRecord features an object-wise saving mechanism, whereas **MaglevRecord can only save all objects marked as persistent at once**. That is the Smalltalk image idea: make some changes and then save the whole world.

```ruby
book = Book.new(:title => "A new book", :author => "The writer")
another_book = Book.new(:title => "Another new book", :author => "The writer")
MaglevRecord.save
```

*Important:* When using MaglevRecord in a Rails app, unsaved changes are lost at the end of the request (die to an automatic request-wrapper).

### Accessing model objects

Rooted model classes (```ActiveRecord::RootedBase```) implement ```Enumerable```, so you can just use the normal collection API.
You can use these methods for queries. Dynamic finders and indexes will be implemented later.
```ruby
 book = Book.find { |b| b.author == "The writer" }
 #book.select
 #book.map
 #etc.
```

Ordinary model classes (```ActiveRecord::Base```) do not provide a mechanism access such models directly. They are used only for referencing such models from other models, i.e. if the model is not reachable from a rooted model, the garbage collector will remove it after some time.

### Deleting models

Rooted models can be deleted with ```delete```. 

*Warning:* This will only remove the model from the enumeration of all models. This model will not be removed until the last reachable reference to it is removed.

### Validation

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

Using ```book.valid?``` you can determine if a model is valid. Models are *not* automatically validated on global save.

### Resetting objects

Use ```MaglevRecord.reset``` the reset all changed made since the last save or reset.

## Further questions, improvements?

Feel free to fork, pull-request or ask via email at bp2012h1 [at] hpi.uni-potsdam.de.
We are actively developing this and hope for feedback.
