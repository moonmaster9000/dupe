Feature: mocking resources
  As a developer
  I want to mock service responses
  So that I can cuke my application without worrying about whether or not I can connect to the service

Scenario: mocking simple, unassociated resources
  Given I have no resource definitions
  When I create an empty "book"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [{"id"=>1}]
  """
  And Dupe should mock the response to "/books/1.xml" with 
  """
  {"id"=>1}
  """

Scenario: mocking complex resources with associations
  Given I have an author resource
  And a book that has one author
  When I create an author named "Arthur C. Clarke"
  And I create a book titled "2001: A Space Odyssey" written by "Arthur C. Clarke"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [{"id"=>1, "title" => "2001: A Space Odyssey", "author" => {"id" => 1, "name" => "Arthur C. Clarke", "label" => "arthur-c-clarke"}}]
  """
  And Dupe should mock the response to "/books/1.xml" with 
  """
  {"id"=>1, "title" => "2001: A Space Odyssey", "author" => {"id" => 1, "name" => "Arthur C. Clarke", "label" => "arthur-c-clarke"}}
  """
  And Dupe should mock the response to "/authors.xml" with
  """
  [{"id" => 1, "name" => "Arthur C. Clarke", "label" => "arthur-c-clarke"}]
  """
  And Dupe should mock the response to "/authors/1.xml" with 
  """
  {"id" => 1, "name" => "Arthur C. Clarke", "label" => "arthur-c-clarke"}
  """

@prefix
Scenario: mocking active resource with prefixes
  Given a PrefixBook ActiveResource object with a site prefix "/book_services"
  When I create an empty "prefix_book"
  Then Dupe should mock the response to "/book_services/prefix_books.xml" with
  """
  [{"id"=>1}]
  """
