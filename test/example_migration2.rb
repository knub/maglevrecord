
m = Migration.new(timestamp)
m.forClass(Book).up.add_attribute(:author, "")
m.forClass(Book).down.remove_attribute(:author)

# erste Zeile generieren
m2 = Migration.new(timestamp).after(m)
m.forClass(Person, Street).up.move_attributes(:street_name => :name)









