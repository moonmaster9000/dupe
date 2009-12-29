begin
  After do
    # print the requests logged during the scenario if in Dupe debug mode
    puts Dupe.network.log.pretty_print if Dupe.debug
    
    # remove any data created during the scenario from the dupe database
    Dupe.database.truncate_tables
    
    # clear out the network log
    Dupe.network.log.reset
  end
rescue
end