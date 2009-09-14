Feature: finding resources
  As a developer
  I want to find resources
  so that I can create associations between resources

Scenario: finding a resource by exact match
  Given an author named "Jo"
  And an author named "Joseph"
  When I search for an "author" with name "Jo"
  Then I should find:
  """
  {:id => 1, :name => "Jo"}
  """
  When I search for "authors" with name "Jo"
  Then I should find: 
  """
  [{:id => 1, :name => "Jo"}]
  """

Scenario: finding a resource by regular expression match
  Given an author named "Jo"
  And an author named "Joseph"
  When I search for "authors" with name like "Jo"
  Then I should find:
  """
  [{:id => 1, :name => "Jo"}, {:id => 2, :name => "Joseph"}]
  """
  When I search for "author" with name like "Jo"
  Then I should find:
  """
  {:id => 1, :name => "Jo"}
  """

Scenario: finding a resource by multiple conditions
  Given an author with first name "Jo" and last name "Joneses"
  And an author with first name "Joseph" and last name "Jones"
  When I search for "authors" with first name like "Jo" and last name like "Jo"
  Then I should find:
  """
  [{:id => 1, :first_name => "Jo", :last_name => "Joneses"}, {:id => 2, :first_name => "Joseph", :last_name => "Jones"}]
  """
  When I search for "author" with first name like "Jo" and last name like "Jo"
  Then I should find:
  """
  {:id => 1, :first_name => "Jo", :last_name => "Joneses"}
  """
  When I search for "authors" with first name like "Jo" and last name "Jones"
  Then I should find: 
  """
  [{:id => 2, :first_name => "Joseph", :last_name => "Jones"}]
  """

Scenario: finding a resource by nested resource conditions
  Given I have an author resource
  And a book that has one author
  And an author named "Jo"
  And an author named "Jones"
  And a book "Jo's Autobiography" written by "Jo" 
  And a book "Jones's Autobiography" written by "Jones"
  When I search for "books" written by authors named "Jo"
  Then I should find:
  """
  [{:id => 1, :title => "Jo's Autobiography", :author => {:id => 1, :name => "Jo"}}]
  """
  When I search for "books" written by authors named like "Jo"
  Then I should find:
  """
  [{:id => 1, :title => "Jo's Autobiography", :author => {:id => 1, :name => "Jo"}}, {:id => 2, :title => "Jones's Autobiography", :author => {:id => 2, :name => "Jones"}}]
  """
  When I search for "book" written by authors named "Jones"
  Then I should find:
  """
  {:id => 2, :title => "Jones's Autobiography", :author => {:id => 2, :name => "Jones"}}
  """
  When I search for "book" written by authors named like "Jo"
  Then I should find:
  """
  {:id => 1, :title => "Jo's Autobiography", :author => {:id => 1, :name => "Jo"}}
  """
  When I search for "books" written by authors named like "Unknown"
  Then I should find: 
  """
  []
  """
  When I search for "book" written by authors named like "Unknown"
  Then I should find: 
  """
  nil
  """


Scenario: finding all records
  Given an author with first name "Jo" and last name "Joneses"
  And an author with first name "Joseph" and last name "Jones"
  When I search for "authors"
  Then I should find:
  """
  [{:id => 1, :first_name => "Jo", :last_name => "Joneses"}, {:id => 2, :first_name => "Joseph", :last_name => "Jones"}]
  """
  When I search for "author"
  Then I should find:
  """
  {:id => 1, :first_name => "Jo", :last_name => "Joneses"}
  """
  When I search for "all" "authors" 
  Then I should find:
  """
  [{:id => 1, :first_name => "Jo", :last_name => "Joneses"}, {:id => 2, :first_name => "Joseph", :last_name => "Jones"}]
  """
  When I search for "first" "author"
  Then I should find:
  """
  {:id => 1, :first_name => "Jo", :last_name => "Joneses"}
  """


Scenario: find a resource with explicit :all or :first
  Given 2 "buck" deer 
  And a "doe" deer named "bambi"
  When I search for "all" "deer"
  Then I should find:
  """
  [{:id => 1, :name => "buck1", :sex => "buck"}, {:id => 2, :name => "buck2", :sex => "buck"}, {:id => 3, :name => "bambi", :sex => "doe"}]
  """
  When I search for "first" "deer"
  Then I should find:
  """
  {:id => 1, :name => "buck1", :sex => "buck"}
  """
  When I search for "all" "deer" with name like "buck"
  Then I should find: 
  """
  [{:id => 1, :name => "buck1", :sex => "buck"}, {:id => 2, :name => "buck2", :sex => "buck"}]
  """
  When I search for "first" "deer" with name like "bambi"
  Then I should find:
  """
  {:id => 3, :name => "bambi", :sex => "doe"}
  """
  When I search for "all" "deer" with sex "doe"
  Then I should find:
  """
  [{:id => 3, :name => "bambi", :sex => "doe"}]
  """
