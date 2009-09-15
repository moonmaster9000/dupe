Given /^I have configured Dupe to mock by id and label$/ do
  Dupe.configure :book do |configure|
    configure.record_identifiers :id, :label
  end
end

When /^I create a book "([^\"]*)" labeled "([^\"]*)"$/ do |title, label|
  Dupe.create :book, :title => title, :label => label
end


When /^I configured Dupe to log requests$/ do
  @old_value = Dupe.global_configuration.config[:debug]
  Dupe.configure do |global_config|
    global_config.debug true
  end
end

Then /^the debug option in the global configuration should be$/ do |code|
  eval(code) == Dupe.global_configuration.config[:debug]
  Dupe.configure do |global_config|
    global_config.debug @old_value.first
  end
end
