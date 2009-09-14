Given /^I have no resource definition for "([^\"]*)"$/ do |resource_name|
  ResourceFactory.flush nil, true
end

When /^I mock a simple book resource$/ do
  ResourceFactory.create :book, :author => 'test_name'  
end

Then /^ResourceFactory should contain that resource record exactly as I specified it$/ do
  ResourceFactory.factories[:book].records.include? :author => 'test_name'
end

Given /^I have a book resource definition with author defaulted to "([^\"]*)"$/ do |author_name|
  ResourceFactory.define :book do |define|
    define.author author_name
  end
end

When /^I mock a book titled "([^\"]*)"$/ do |title|
  ResourceFactory.create :book, :title => title
end

Then /^ResourceFactory should set the author of "([^\"]*)" to "([^\"]*)"$/ do |title, author|
  ResourceFactory.factories[:book].records.include?(:author => author, :title => title, :id => 1).should == true
end

Given /^I have an author definition with name defaulted to "([^\"]*)"$/ do |name|
  ResourceFactory.define :author do |define|
    define.name name
  end
end

Given /^a book definition where author associates to the author record$/ do
  ResourceFactory.define :book do |define|
    define.author do |name|
      ResourceFactory.find(:author) {|a| a.name == name}
    end
  end
end

When /^I create an author$/ do
  ResourceFactory.create :author
end

When /^When I create a book associated with that author$/ do
  ResourceFactory.create :book, :title => 'test book', :author => 'Anonymous'
end

Then /^ResourceFactory should contain a book record with the author record embedded$/ do
  records = [{:title => 'test book', :id => 1, :author => {:id => 1, :name => 'Anonymous'}}]
  records.should == ResourceFactory.factories[:book].records 
end

Given /^I have an author definition with name transformed to "([^\"]*)"$/ do |author_substitute|
  ResourceFactory.define :author do |define|
    define.name do |n|
      author_substitute
    end
  end
end

When /^I create an author named "([^\"]*)"$/ do |name|
  ResourceFactory.create :author, :name => name 
end

Then /^ResourceFactory should contain an author record with the name "([^\"]*)"$/ do |name|
  records = [{:name => name, :id => 1}]
  records.should == ResourceFactory.factories[:author].records
end

When /^I create "([^\"]*)" (?:more )?books$/ do |num_records|
  ResourceFactory.create(:book, [{}] * num_records.to_i)
end

Then /^the books factory should contain "([^\"]*)" records with the ids "([^\"]*)" through "([^\"]*)"$/ do |total, start_id, end_id|
  ResourceFactory.factories[:book].records.size.should == total.to_i
  records = []
  (start_id.to_i..end_id.to_i).each do |id|
    records << {:id => id}
  end
  ResourceFactory.factories[:book].records.should == records
end
