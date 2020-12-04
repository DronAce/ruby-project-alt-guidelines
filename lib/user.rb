class User < ActiveRecord::Base
    has_many :reviews
    has_many :books, through: :reviews
    has_many :read_books
    has_many :books, through: :read_books 

    # def self.login
    #     puts "You chose Login"
    # end
    
    # def self.register
    #     puts "You chose Register"
    # end
end