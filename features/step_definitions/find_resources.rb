Given /^an author named "([^\"]*)"$/ do |author_name|
  Dupe.create :author, :name => author_name
end

When /^I search for(?: an)? "([^\"]*)" with name "([^\"]*)"$/ do |resource, name|
  @results = Dupe.find(resource.to_sym) { |r| r.name == name }
end

When /^I search for "([^\"]*)" with name like "([^\"]*)"$/ do |resource, name|
  @results = Dupe.find(resource.to_sym) { |r| /#{name}/ === r.name }
end

Then /^I should find:$/ do |expected_result|
  @results.should == eval(expected_result)
end

Given /^an author with first name "([^\"]*)" and last name "([^\"]*)"$/ do |first_name, last_name|
  Dupe.create :author, :first_name => first_name, :last_name => last_name
end

When /^I search for "([^\"]*)" with first name like "([^\"]*)" and last name like "([^\"]*)"$/ do |resource, first_name, last_name|
  @results = Dupe.find(resource.to_sym) {|r| /#{first_name}/ === r.first_name  and /#{last_name}/.match(r.last_name) }
end

When /^I search for "([^\"]*)" with first name like "([^\"]*)" and last name "([^\"]*)"$/ do |resource, first_name, last_name|
  @results = Dupe.find(resource.to_sym) {|r| r.last_name == last_name and /#{first_name}/.match(r.first_name) }
end

When /^I search for "([^\"]*)"$/ do |resource|
  @results = Dupe.find(resource.to_sym)
end

When /^I search for "([^\"]*)" "([^\"]*)"$/ do |all_or_first, resource|
  @results = Dupe.find(all_or_first.to_sym, resource.to_sym)
end

Given /^a book "([^\"]*)" written by "([^\"]*)"$/ do |title, author_name|
  Dupe.create :book, :title => title, :author => author_name
end

When /^I search for "([^\"]*)" written by authors named "([^\"]*)"$/ do |resource, author_name|
  @results = Dupe.find(resource.to_sym) {|b| b.author.name == author_name}
end

When /^I search for "([^\"]*)" written by authors named like "([^\"]*)"$/ do |resource, author_name|
  @results = Dupe.find(resource.to_sym) {|b| /#{author_name}/ === b.author.name}
end

Given /^(\d+) "([^\"]*)" deer$/ do |count, type|
  Dupe.stub(
    :deer,
    :template => {:name => 'buck', :type => type},
    :count    => count.to_i,
    :sequence => :name
  )
end

Given /^a "([^\"]*)" deer named "([^\"]*)"$/ do |type, name|
  Dupe.create :deer, :name => name, :type => type
end

When /^I search for "([^\"]*)" "([^\"]*)" with name like "([^\"]*)"$/ do |all_or_first, resource, name|
  @results = Dupe.find(all_or_first.to_sym, resource.to_sym) {|d| d.name.include? name}
end

When /^I search for "([^\"]*)" "([^\"]*)" with type "([^\"]*)"$/ do |all_or_first, resource, type|
  @results = Dupe.find(all_or_first.to_sym, resource.to_sym) {|d| d.type == type}
end
