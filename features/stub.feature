Feature: Stubbing large numbers of resources
  As a developer
  I want to stub out a large number of resource responses with a single command
  So that I don't develop carpal tunnel syndrome typing out all of those resources!

Scenario: stubbing simple resources
  When I stub 5 books starting with the title "stubby 1"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "stubby 1"},
    {"id" => 2, "title" => "stubby 2"},
    {"id" => 3, "title" => "stubby 3"},
    {"id" => 4, "title" => "stubby 4"},
    {"id" => 5, "title" => "stubby 5"}
  ]
  """
  When I stub 5 more books starting with the title "stubsville 9000"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "stubby 1"},
    {"id" => 2, "title" => "stubby 2"},
    {"id" => 3, "title" => "stubby 3"},
    {"id" => 4, "title" => "stubby 4"},
    {"id" => 5, "title" => "stubby 5"},
    {"id" => 6, "title" => "stubsville 9000"},
    {"id" => 7, "title" => "stubsville 9001"},
    {"id" => 8, "title" => "stubsville 9002"},
    {"id" => 9, "title" => "stubsville 9003"},
    {"id" => 10, "title" => "stubsville 9004"}
  ]
  """

Scenario: stubbing complex resources
  Given I have an author resource
  And a book that has one author
  When I create an author named "stubmeister"
  And  I stub 5 books starting with the title "stubby 1" written by "stubmeister"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "stubby 1", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 2, "title" => "stubby 2", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 3, "title" => "stubby 3", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 4, "title" => "stubby 4", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 5, "title" => "stubby 5", "author" => {"id" => 1, "name" => "stubmeister"}}
  ]
  """
  When I stub 5 more books starting with the title "stubsville 9000" written by "stubmeister"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "stubby 1", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 2, "title" => "stubby 2", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 3, "title" => "stubby 3", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 4, "title" => "stubby 4", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 5, "title" => "stubby 5", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 6,   "title" => "stubsville 9000", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 7,   "title" => "stubsville 9001", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 8,   "title" => "stubsville 9002", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 9,   "title" => "stubsville 9003", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 10,  "title" => "stubsville 9004", "author" => {"id" => 1, "name" => "stubmeister"}}
  ]
  """
