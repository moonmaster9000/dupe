Feature: configure
  As a developer
  I want to configure record identifiers
  so that Dupe will mock responses to services that my application tries to hit. 

Scenario: mock id and label
  Given I have configured Dupe to mock by id and label
  When I create a book "2001: A Space Odyssey" labeled "2001-a-space-odyssey"
  And I create a book "Rendezvous with Rama" labeled "rendezvous-with-rama"
  Then Dupe should mock the response to "/books/1.xml" with:
  """
  {"id" => 1, "title" => "2001: A Space Odyssey", "label" => "2001-a-space-odyssey"}
  """
  And Dupe should mock the response to "/books/2001-a-space-odyssey.xml" with:
  """
  {"id" => 1, "title" => "2001: A Space Odyssey", "label" => "2001-a-space-odyssey"}
  """
  Then Dupe should mock the response to "/books/2.xml" with:
  """
  {"id" => 2, "title" => "Rendezvous with Rama", "label" => "rendezvous-with-rama"}
  """
  And Dupe should mock the response to "/books/rendezvous-with-rama.xml" with:
  """
  {"id" => 2, "title" => "Rendezvous with Rama", "label" => "rendezvous-with-rama"}
  """
