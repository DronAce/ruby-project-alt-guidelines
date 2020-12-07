require "tty-prompt"
require "pry"
require "rainbow"


class CLI 

    @@prompt = TTY::Prompt.new
    @@artii1 = Artii::Base.new :font => 'banner3'    
    # @@artii2 = Artii::Base.new :font => ''
    @@user = nil
    def splash
        puts Rainbow(@@artii1.asciify("Novels.com")).gold
    end

    def startup
        sleep(1)
        Rainbow(@@artii1.asciify("Novels.com")).gold
        sleep(1)
    end
    
    def welcome
        system ('clear')
        self.startupArtiisleep(1.5)
        self.main_menu
    end
    
    
    def greet
        self.splash
        puts"hello"
    end

    ##LOGIN IN SCREENS

    def main_menu
        system ('clear')
        self.splash
        puts
        splash = @@prompt.select ("Please Log In or Sign up!") do |prompt|
            prompt.choice "Log In", -> {login_helper}
            prompt.choice "Register", -> {register_helper}
            prompt.choice "Exit", -> {close_helper}
        end
        # case splash
        # when "Log In"
        #     self.
        # end

    end

#helpers for main_menu
    def login_helper
        system ('clear')
        self.splash
        puts
        username = @@prompt.ask("Enter User Name")
        password = @@prompt.mask("Enter Password")
        @@user = User.find_by(name: username , password: password)
        if @@user
            self.login_main_menu
        else
            system ('clear')
            self.splash
            puts "Username or password don't exist"
            sleep(1)
            puts "...loading previous page..."
            sleep(1)
            self.main_menu
        end
    end

    def register_helper
        system 'clear'
        self.splash
        puts
        username = @@prompt.ask("Enter Username")
        if User.find_by(name: username)
            puts "Username not Available"
            sleep(3)
            self.register_helper
        else
            password = @@prompt.ask("Enter your New Password")
            @@user = User.create(name: username, password: password)
            puts "Thanks for joining us"
            sleep(1)
            self.login_main_menu
        end
    end

    def close_helper
        system 'clear'
        puts "Bye Bye"
        sleep(1)
    end

    ##after succesfull login
    def login_main_menu
        system 'clear'
        self.splash
        puts
        menu = @@prompt.select ("Main Menu") do |prompt|
            prompt.choice "Add a New Book", -> {create_book}
            prompt.choice "See a list of all Books", -> {list_books_menu}
            prompt.choice "Create a New Review", ->{create_reviews}
            prompt.choice "See your reviews", -> {user_review_results}
            prompt.choice "Update an existing Review", -> {update_review}
            prompt.choice "All Reviews", -> {all_reviews}
            prompt.choice Rainbow("Delete a Review").red, -> {review_delete_menu}
            prompt.choice Rainbow("Delete a User").red, -> {delete_user_menu}
            prompt.choice "Exit", -> {close_helper}
        end
            
    end

    #create read book
    def read_book(id)
        read = ReadBook.new
        read.user_id = @@user.id
        read.book_id = id
        read.save
        author = Book.all.select{|book| book.id == id}.map{|book| book.author}
        puts author
    end

    ##Book Methods##

    def create_book
        system 'clear'
        self.splash
        puts
        puts Rainbow("ENTER NEW BOOK \n").lightseagreen
        book_title = @@prompt.ask("Enter the book Title?")
        book_author = @@prompt.ask("Enter name of the Author?")
        if Book.all.any? {|book| book.title == book_title}
            puts "Hey, It looks like #{book_title} already exists"
        else
            new_book = Book.create(title: book_title, author: book_author)
            puts "Book: '#{new_book.title}' has been entered!"
        end
        self.login_main_menu
    end
    
    def list_books_menu
        system 'clear'
        self.splash
        puts
        puts Rainbow("ALL BOOKS IN THE SYSTEM \n").lightseagreen
        self.list_books
    end

    def list_books
        titles = Book.all.order(title: :ASC)
        titles = titles.map do |book| 
            book.title ||= {}
            book.title = {book.title => book.id}
        end
        selection = @@prompt.select("Select A Book ", titles)
        read_delete = @@prompt.select("") do |prompt|
            prompt.choice Rainbow("DELETE").red, -> {delete_book(selection)}
            prompt.choice Rainbow("READ").green, -> {read_book(selection)}
        end
        menu = @@prompt.select("\n") do |prompt|
            prompt.choice "Main Menu", -> {login_main_menu}
            prompt.choice "Exit", -> {close_helper}
        end
    end

    
    def book_exist(title)
        check = Book.all.any? {|book| book.title == title}
    end

    

    ##Review Methods##

    def user_review_results
        system 'clear'
        self.splash
        puts '\n \n'
        puts Rainbow("YOUR REVIEWS \n").lightseagreen
        puts ''
        self.user_reviews.each do |review|
            puts "You have read #{Rainbow(review.book.title).orange}, and gave it the following review: #{Rainbow(review.review).orange}"
        end
        menu = @@prompt.select("\n") do |prompt|
            prompt.choice "Main Menu", -> {login_main_menu}
            prompt.choice "Exit", -> {close_helper}
        end
    end

    
    def create_reviews
        system 'clear'
        self.splash
        puts
        puts Rainbow("CREATE NEW REVIEW \n").lightseagreen
        book_title = @@prompt.ask("What is the Book Title?")
        if (book_exist(book_title) == true) && (review_exist(book_title) == false)
            review = @@prompt.ask("What did you think about the Book?")
            book = Book.find_by(title: book_title)
            new_review = Review.create(user: @@user, book: book, review: review)
            puts "New Review entered! You have given the following review #{Rainbow(new_review.review).orange}"
        elsif (book_exist(book_title) && review_exist(book_title) == true)
            old_review = Review.all.select {|review| (review.book.title == book_title) && (review.user.name == @@user.name)}.first
            puts "\n You have previously given #{Rainbow(book_title).orange} the following review: #{Rainbow(old_review.review).orange}"
        else
            puts "\n Sorry #{Rainbow(@@user.name).orange}, but #{Rainbow(book_title).orange} doesn't exist in our system yet. "
        end
        menu = @@prompt.select("\n") do |prompt|
            prompt.choice "Main Menu", -> {login_main_menu}
            prompt.choice "Exit", -> {close_helper}
        end
        
    end

    ## def all_reviews

    def all_reviews
        reviews = Review.all
        reviews.each do |review| 
            puts Rainbow(review.book.title).aqua
            puts review.review
            puts review.user.name 
        end
        menu = @@prompt.select("\n") do |prompt|
            prompt.choice "Main Menu", -> {login_main_menu}
            prompt.choice "Exit", -> {close_helper}      
        end
    end


    ## also on main manu
    def update_review
        system 'clear'
        self.splash
        if has_review
            puts "\n List of My reviews"
            titles = user_reviews.map do |review| 
                review.book.title ||= {}
                review.book.title = {review.book.title => review.id}
            end
            selection = @@prompt.select("Select A Review ", titles)
            to_update = Review.find_by(user_id: @@user.id, id: selection)
            update = @@prompt.ask("Enter a Review")
            to_update.update(review: update)
            puts "The review has been updated"
            menu = @@prompt.select("\n") do |prompt|
                prompt.choice "Main Menu", -> {login_main_menu}
                prompt.choice "Exit", -> {close_helper}
            end
        else 
            puts "\n You don't have a review"
            menu = @@prompt.select("\n") do |prompt|
                prompt.choice "Main Menu", -> {login_main_menu}
                prompt.choice "Exit", -> {close_helper}
            end
        end
    end

    #Review Checkers
    def user_reviews
        results = Review.all.select {|review| review.user_id == @@user.id}
        results  
    end

    def book_reviews(id)
        results = Review.all.select {|review| review.book_id == id}
        results
    end

    def review_exist(title)
        check = Review.all.any? {|review|  (review.book.title == title) && (review.user.name == @@user.name)}
    end

    def has_review
        user_reviews.count > 0 ? true : false
    end

    def delete_all_user_reviews
        if has_review
            user_reviews.destroy_all
        end
    end
    
    ##delete methods##
    
    def review_delete_menu
        system 'clear'
        self.splash
        if has_review
            puts Rainbow("DELETE REVIEW").red
            puts
            titles = user_reviews.map do |review| 
                review.book.title ||= {}
                review.book.title = {review.book.title => review.id}
            end
            selection = @@prompt.select("Select Review for Deletion (this cannot be reversed)", titles)
            delete_review(selection)
            sleep(1)
            puts
            puts "the review has been removed from your history."
            menu = @@prompt.select("\n") do |prompt|
                prompt.choice "Main Menu", -> {login_main_menu}
                prompt.choice "Exit", -> {close_helper}
            end
        else
            puts "\n You don't have a review"
            menu = @@prompt.select("\n") do |prompt|
                prompt.choice "Main Menu", -> {login_main_menu}
                prompt.choice "Exit", -> {close_helper}
            end
        end
    end
    
    def delete_review(id)
        review = Review.find_by(user_id: @@user.id, id: id)
        review.destroy
    end

    def delete_book(id)
        Book.delete(id)
    end



    def delete_user_menu
        system 'clear'
        self.splash
        puts 
        puts Rainbow("DELETE USER").red
        puts 
        menu = @@prompt.select("Are you sure you want to delete your user? (this cannot be reversed)") do |prompt|
            prompt.choice Rainbow("Yes").red
            prompt.choice 'No'
        end
        case menu
        when Rainbow("Yes").red
            User.delete(@@user)
            delete_all_user_reviews
            # sleep(0.5)
            system('clear')
            self.splash
            puts
            puts "Your account: #{Rainbow(@@user.name).coral} was #{Rainbow("DELETED").red}. Returning to login menu."
            sleep(3)
            self.main_menu
        when "No"
            # sleep(1)
            self.login_main_menu
        end
    end


    def delete_all_book_reviews
        book_reviews.destroy_all
    end
    
end