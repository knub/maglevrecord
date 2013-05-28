# MagLevRecord - a model interface for Rails
[![Build Status master](https://travis-ci.org/knub/maglevrecord.png?branch=master)](https://travis-ci.org/knub/maglevrecord)
[![Code Climate](https://codeclimate.com/github/knub/maglevrecord.png)](https://codeclimate.com/github/knub/maglevrecord)

```ActiveRecord``` is the ORM commonly used when working with Rails and relational databases.
When using MagLev, using an ORM is no longer necessary, **you can just work with your objects as they are**.
Still, ```ActiveRecord::Base``` offers some nice features for working with your models (*e.g.* like Validations).

This gem offers all those features and bundles them in a comfortable way.

### Installation

```gem install maglevrecord```


## Basic Usage

### Creating classes

Models, which you wish to persist, have to include ```MaglevRecord::Base``` or ```MaglevRecord::RootedBase```.
You can still inherit from whatever base class you want.

The difference between ```RootedBase``` and ```Base``` is, that ```RootedBase``` automatically stores the
instances in ```Maglev::PERSISTENT_ROOT``` ([persistence by reachability](http://maglevity.wordpress.com/2010/01/17/persistence-by-reachability/)).
The instances are stored in a hash, which contains all instances of the class.

When using ```Base``` you are responsible for making the object reachable from ```PERSISTENT_ROOT```.


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


### Migrating objects

Have a look at the [demo application for migrations](https://github.com/niccokunzmann/maglevrecord-demo/blob/master/README.md).

## Further questions, improvements?

Feel free to fork, pull-request or ask via email at bp2012h1 [at] hpi.uni-potsdam.de.
We are actively developing this and hope for feedback.
