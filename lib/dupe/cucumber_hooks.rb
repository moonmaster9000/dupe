After do |scenario| #:nodoc:
  if Dupe.global_configuration.config[:debug] == true
    ActiveResource::Connection.print_request_log 
    ActiveResource::Connection.flush_request_log
  end

  Dupe.flush
end 
