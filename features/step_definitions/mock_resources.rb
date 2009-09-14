Given /^I have no resource definitions$/ do
  Dupe.flush nil, true
end

When /^I create an empty "([^\"]*)"$/ do |resource_name|
  Dupe.create resource_name.to_sym
end

Then /^Dupe should mock the response to "([^\"]*)" with$/ do |url, response|
  @conn = ActiveResource::Connection.new('http://localhost')
  @conn.get(url).should == eval(response)
end


Given /^I have an author resource$/ do
end

Given /^a book that has one author$/ do
  Dupe.define :book do |define|
    define.author do |name|
      Dupe.find(:author) {|a| a.name == name}
    end
  end
end

When /^I create a book titled "([^\"]*)" written by "([^\"]*)"$/ do |title, author_name|
  Dupe.create :book, :title => title, :author => author_name
end

When /^I stub (\d+) (?:more )?books starting with the title "([^\"\ ]* )(\d+)"$/ do |count, title, sequence_start|
  Dupe.stub :book,                                                      
    :template => {:title => title},                                                
    :sequence_start_value => sequence_start.to_i,                                  
    :count => count.to_i                                                           
end

When /^I stub (\d+) (?:more )?books starting with the title "([^\"\ ]* )(\d+)" written by "([^\"]*)"$/ do |count, title, sequence_start, author_name|
  Dupe.stub :book,                                                      
    :template => {:title => title, :author => author_name},                                                
    :sequence_start_value => sequence_start.to_i,                                  
    :count => count.to_i                                                           
end
