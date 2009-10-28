Dupe.configure do |global_config|
  # set this to false if you don't want to see the mocked
  # xml output after each scenario
  global_config.debug true
end

# You can also place your resource definitions in this file. 
=begin
  # Example resource definition
  Dupe.define :books do |book|
    book.name 'default name'

    # supporting Dupe.create :book, :genre => 'Sci-fi'
    book.genre do |genre_name|
      Dupe.find(:genre) {|g| g.name == genre_name}
    end

    # supporting Dupe.create :book, :authors => 'Arthur C. Clarke, Gentry Lee'
    book.authors do |author_names|
      Dupe.find(:authors) {|a| author_names.split(/,\ */).include?(a.name)}
    end
  end
=end
