class Book < ActiveRecord::Base
    has_many :reviews
    has_many :users, through: :reviews
    has_many :read_books
    has_many :users, through: :read_books
end