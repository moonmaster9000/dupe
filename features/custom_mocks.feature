@custom_mocks
Feature: custom mocks
  This will supercede Dupe.define_mocks (which was too clunky an interface to be practical). 

  Basically, it's like a method_missing for your service. For any service request urls
  not already mocked by Dupe via ActiveResource::HttpMock, it will fall through to a list
  of regex's, which then map to Dupe.find's. 
  
  @count
  Scenario: A custom "count" mock
    Given a book resource
    When I define a custom `count` mock for "books"
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

  @lookup
  Scenario: A custom mock for looking up books by author
    Given I have an author resource
    And a book that has one author
    When I create an author named "Arthur C. Clarke"
    And I create a book titled "2001: A Space Odyssey" written by "Arthur C. Clarke"
    And I define a custom mock for retreiving books written by a particular author
    Then Dupe should mock the response to "/books.xml?author_id=arthur-c-clarke" with:
    """
    [{"id"=>1, "title" => "2001: A Space Odyssey", "author" => {"id" => 1, "name" => "Arthur C. Clarke", "label" => "arthur-c-clarke"}}]
    """
    
