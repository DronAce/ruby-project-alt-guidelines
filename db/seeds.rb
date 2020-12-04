Book.destroy_all
User.destroy_all
ReadBook.destroy_all
Review.destroy_all

#CREATE
#books
dragonball = Book.new(title: "Dragon Ball", author: "Akira Toriyama")
dragonball.save
harry = Book.create(title: "Harry Potter", author: "JK Rowling")

#users
oke = User.create(name: "Okechukwu", password: "abc123")
julio = User.create(name: "Julio", password: "a")

#read books
ReadBook.create(title: "Dragon Ball", user_id: oke.id, book_id: dragonball.id)



#reviews 
Review.create(review: "This comic book is awesome!!!", user_id: oke.id, book_id: dragonball.id)