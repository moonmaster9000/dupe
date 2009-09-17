When /^I stub (\d+) (?:more )?books starting with the title "([^\"\ ]*) (\d+)"$/ do |count, title, sequence_start|
  Dupe.stub count.to_i, :books, :like => {:title => proc {|n| "#{n}-#{title}"}}, :starting_with => sequence_start.to_i
end

When /^I stub (\d+) (?:more )?books starting with the title "([^\"\ ]*) (\d+)" written by "([^\"]*)"$/ do |count, title, sequence_start, author_name|
  Dupe.stub( 
    count.to_i, 
    :books, 
    :like => {:title => proc {|n| "#{n}-#{title}"}, :author => author_name}, 
    :starting_with => sequence_start.to_i
  )
end
