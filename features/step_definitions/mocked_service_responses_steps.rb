Given /^I have duped an object$/ do
  Dupe.define :book do |attrs|
    attrs.title 'Untitled'
    attrs.author 
  end
  @book = Dupe.create :book
end

When /^I request that object via the RESTful url for the object$/ do
  @conn = ActiveResource::Connection.new('http://localhost')
end

Then /^Dupe should return the appropriate xml for the duped object$/ do
  @conn.get("/books/#{@book.id}.xml").should == %{<?xml version="1.0"><book><title>Untitled</title><author nil="true" /></book>}
end
