Feature: defining and creating resources
  As a behavior-driven developer
  I want to create resource definitions
  So that I can mock service responses

Scenario: no resource definition required
  Given I have no resource definition for "book"
  When I mock a simple book resource
  Then Dupe should contain that resource record exactly as I specified it

Scenario: resource definition with default values for attributes
  Given I have a book resource definition with author defaulted to "Anonymous"
  When I mock a book titled "Bible"
  Then Dupe should set the author of "Bible" to "Anonymous"

Scenario: resource definition with attribute association
  Given I have an author definition with name defaulted to "Anonymous"
  And a book definition where author associates to the author record
  When I create an author
  And When I create a book associated with that author
  Then Dupe should contain a book record with the author record embedded

Scenario: resource definition with attribute transformation
  Given I have an author definition with name transformed to "transformed name"
  When I create an author named "this will get changed"
  Then Dupe should contain an author record with the name "transformed name"

Scenario: sequential ids
  When I create "5" books
  Then the books factory should contain "5" records with the ids "1" through "5"
  When I create "5" more books
  Then the books factory should contain "10" records with the ids "1" through "10"
