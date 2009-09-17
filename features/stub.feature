Feature: Stubbing large numbers of resources
  As a developer
  I want to stub out a large number of resource responses with a single command
  So that I don't develop carpal tunnel syndrome typing out all of those resources!

@simplestub
Scenario: stubbing simple resources
  When I stub 5 books starting with the title "stubby 1"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "1-stubby"},
    {"id" => 2, "title" => "2-stubby"},
    {"id" => 3, "title" => "3-stubby"},
    {"id" => 4, "title" => "4-stubby"},
    {"id" => 5, "title" => "5-stubby"}
  ]
  """
  When I stub 5 more books starting with the title "stubsville 9000"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "1-stubby"},
    {"id" => 2, "title" => "2-stubby"},
    {"id" => 3, "title" => "3-stubby"},
    {"id" => 4, "title" => "4-stubby"},
    {"id" => 5, "title" => "5-stubby"},
    {"id" => 6, "title" => "9000-stubsville"},
    {"id" => 7, "title" => "9001-stubsville"},
    {"id" => 8, "title" => "9002-stubsville"},
    {"id" => 9, "title" => "9003-stubsville"},
    {"id" => 10, "title" => "9004-stubsville"}
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
    {"id" => 1, "title" => "1-stubby", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 2, "title" => "2-stubby", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 3, "title" => "3-stubby", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 4, "title" => "4-stubby", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 5, "title" => "5-stubby", "author" => {"id" => 1, "name" => "stubmeister"}}
  ]
  """
  When I stub 5 more books starting with the title "stubsville 9000" written by "stubmeister"
  Then Dupe should mock the response to "/books.xml" with 
  """
  [
    {"id" => 1, "title" => "1-stubby",  "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 2, "title" => "2-stubby",  "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 3, "title" => "3-stubby",  "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 4, "title" => "4-stubby",  "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 5, "title" => "5-stubby",  "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 6, "title" => "9000-stubsville", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 7, "title" => "9001-stubsville", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 8, "title" => "9002-stubsville", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 9, "title" => "9003-stubsville", "author" => {"id" => 1, "name" => "stubmeister"}},
    {"id" => 10,"title" => "9004-stubsville", "author" => {"id" => 1, "name" => "stubmeister"}}
  ]
  """
