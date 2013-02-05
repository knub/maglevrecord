
Migration.new(Book).add_attribute(:author, "J.K.Rohling")

m = Migration.new(Book)
m.attribute(:sold).up {
  book.sold+= 1
}
m.attibute.sold(:sold).down {
  book.sold -= 1
}
 
