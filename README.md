# MagLevRecord - a model interface for Rails

This is intended to replace ActiveRecord::Base when using MagLev. It is not ready for production use, but feel free to play around with it.

## Installation

You can install this gem from rubygems.org:
```gem install maglevrecord```


## Basic Usage

### Creating classes

Classes which you wish to persist have to include ```MaglevRecord::Base```. You can still inherit from whatever base class you want.

```ruby
require 'maglev_record'

class Book
  include MaglevRecord::Base
  
  attr_accessor :author, :title, :comments
end
```
Use attr_reader, attr_writer or attr_accessor to define your fields and use the generated getters and setters to access them. Do not access the instance variables directly, because we need to do some background work when accessing and setting.

### Saving

```MaglevRecord::Base``` offers methods a method for saving an object in the database.

```ruby
book = Book.new(:title => "A new book", :author => "The writer")
book.save
```

However, note that this does not directly save the object in the database, but rather validates and marks the object as ready for saving.
For actually saving the object, you will have to do an ```Maglev.commit_transaction``` afterwards, which saves all objects previously marked.

When using MaglevRecord in an Rails app, you will usually do the ```commit_transaction``` part in an request-wrapper, so the commit will automatically happen at the end of each request.


*Important:*
There must not be any unsaved changes when calling Maglev.commit_transaction, or the request will fail. You must call either ```save``` or ```reset!``` (which resets to the last saved state, read more about it below), if you made changes to an object after the last save.

This will cause an error:

```ruby
 book = Book.new(:title => "A new book", :author => "The writer")
 book.save
 # book saved, everything is fine, now you could commit
 book.author = "Another writer"
 # now the book is marked dirty
 Maglev.commit_transaction # this will fail
```

**Be sure to always call ```save``` or ```reset!``` after a model was changed!** Otherwise committing the transaction into the stone will fail.


### Accessing model objects

Every model class implements ```Enumerable```, so you can just use the normal collection API.
You can use these methods for queries. Dynamic finders and indexes will be implemented later.
```ruby
 book = Book.find { |b| b.author == "The writer" }
 #book.select
 #book.map
 #etc.
```

### Deleting models

Delete models with ```book.delete```.

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

Using ```book.valid?``` you can determine if a model is valid. Models are automatically validated before ```save``` and have to be valid. Validation can be skipped with ```save(:validate => false)```.

### Resetting objects

Attributes with ```attr_accessor``` can be reset if they were changed with the standard setter (```attribute=(value)```). To reset a single attribute call ```attribute_reset!```, to reset the whole model call ```reset!```. 

```ruby
 book = Book.find { |b| b.author == "The writer" }
 book.author = "Another author"
 book.reset_author!
 puts book.author
 # => "The writer"
```

### Migrations

Migrations are still in Progress in the branch feature/migration. Here are some thoughts:

An object diagram of an example migration scenario can be seen below:

![Migration Model](https://raw.github.com/niccokunzmann/maglev-wiki-pictures/master/Migration%200.png)

"EBook" is the class that shall be migrated. 
"e1" and "e2" are two objects of EBook. 
"EBook" has a list "Done" of already applied migrations.
"Wish" is the List of migrations required here.
Migrations "a" and "b" are used here and already applied to "EBook" whereas "c" and "d" as new migrations are yet unknown to "EBook".
"e" and "f" have been applied to "EBook" but are not used here.

Since we can save the source code of all migrations we can imagine rolling back "e" and "f" and applying "c" and "d" instead.


## Further questions, improvements?

Feel free to fork, pull-request or ask via email at bp2012h1 [at] hpi.uni-potsdam.de.
We are actively developing this and hope for feedback.
