Feature: Extending mocks
  As a developer
  I want to add my own custom mocks to Dupe
  So that dupe will mock responses that my application is expecting. 

Scenario: mocking count
  Given a book resource
  When I define a count mock
  And stub 20 books
  Then Dupe should mock the response to "/books/count.xml" with: 
  """
  {"count" => 20}
  """
  When I stub 20 more books
  Then Dupe should mock the response to "/books/count.xml" with: 
  """
  {"count" => 40}
  """

Scenario: mocking count and find by genre
  Given a book resource
  When I define a count mock
  And I define a find by genre mock
  And stub 2 books with genre "Science Fiction"
  And stub 2 books with genre "Fantasy"
  Then Dupe should mock the response to "/books/count.xml" with: 
  """
  {"count" => 4}
  """
  And Dupe should mock the response to "/books.xml?genre=Science+Fiction" with: 
  """
  [{"id" => 1, "name" => "book1", "genre" => "Science Fiction"}, {"id" => 2, "name" => "book2", "genre" => "Science Fiction"}]
  """
  And Dupe should mock the response to "/books.xml?genre=Fantasy" with: 
  """
  [{"id" => 3, "name" => "book3", "genre" => "Fantasy"}, {"id" => 4, "name" => "book4", "genre" => "Fantasy"}]
  """
