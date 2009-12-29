begin
  After do |scenario|
    # print the requests logged during the scenario if in Dupe debug mode
    if Dupe.debug
      log = Dupe.network.log.pretty_print
      puts "\n\n" + log.indent(4) + "\n\n" if log
    end
    
    # remove any data created during the scenario from the dupe database
    Dupe.database.truncate_tables
    
    # clear out the network log
    Dupe.network.log.reset
  end
rescue
end