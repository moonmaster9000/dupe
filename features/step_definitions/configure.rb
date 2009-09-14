Given /^I have configured Dupe to mock by id and label$/ do
  Dupe.configure :book do |configure|
    configure.record_identifiers :id, :label
  end
end

When /^I create a book "([^\"]*)" labeled "([^\"]*)"$/ do |title, label|
  Dupe.create :book, :title => title, :label => label
end
