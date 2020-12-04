class CreateReadBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :read_books do |t|
      t.string  :title
      t.integer :user_id
      t.integer :book_id
    end
  end
end
