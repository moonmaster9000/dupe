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
