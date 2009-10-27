Given /^I have no resource definition for "([^\"]*)"$/ do |resource_name|
  Dupe.flush nil, true
end

When /^I mock a simple book resource$/ do
  Dupe.create :book, :author => 'test_name'  
end

Then /^Dupe should contain that resource record exactly as I specified it$/ do
  Dupe.factories[:book].records.include? :author => 'test_name'
end

Given /^I have a book resource definition with author defaulted to "([^\"]*)"$/ do |author_name|
  Dupe.define :book do |define|
    define.author author_name
  end
end

When /^I mock a book titled "([^\"]*)"$/ do |title|
  Dupe.create :book, :title => title
end

Then /^Dupe should set the author of "([^\"]*)" to "([^\"]*)"$/ do |title, author|
  Dupe.factories[:book].records.include?(:author => author, :title => title, :id => 1).should == true
end

Given /^I have an author definition with name defaulted to "([^\"]*)"$/ do |name|
  Dupe.define :author do |define|
    define.name name
  end
end

Given /^a book definition where author associates to the author record$/ do
  Dupe.define :book do |define|
    define.author do |name|
      Dupe.find(:author) {|a| a.name == name}
    end
  end
end

When /^I create an author$/ do
  Dupe.create :author
end

When /^When I create a book associated with that author$/ do
  Dupe.create :book, :title => 'test book', :author => 'Anonymous'
end

Then /^Dupe should contain a book record with the author record embedded$/ do
  records = [{:title => 'test book', :id => 1, :author => {:id => 1, :name => 'Anonymous'}}]
  records.should == Dupe.factories[:book].records 
end

Given /^I have an author definition with name transformed to "([^\"]*)"$/ do |author_substitute|
  Dupe.define :author do |define|
    define.name do |n|
      author_substitute
    end
  end
end

When /^I create an author named "([^\"]*)"$/ do |name|
  Dupe.create :author, :name => name, :label => name.downcase.gsub(/[^a-zA-Z\ ]/, '').gsub(/\ +/, '-')
end

Then /^Dupe should contain an author record with the name "([^\"]*)"$/ do |name|
  records = [{:name => name, :id => 1}]
  records.collect {|r| {:name => r[:name], :id => r[:id]}}.should == Dupe.factories[:author].records.collect {|r| {:name => r[:name], :id => r[:id]}}
end

When /^I create "([^\"]*)" (?:more )?books$/ do |num_records|
  Dupe.create(:book, [{}] * num_records.to_i)
end

Then /^the books factory should contain "([^\"]*)" records with the ids "([^\"]*)" through "([^\"]*)"$/ do |total, start_id, end_id|
  Dupe.factories[:book].records.size.should == total.to_i
  records = []
  (start_id.to_i..end_id.to_i).each do |id|
    records << {:id => id}
  end
  Dupe.factories[:book].records.should == records
end
