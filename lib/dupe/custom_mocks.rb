def Get(url_pattern, &block)
  Dupe.network.define_service_mock :get, url_pattern, block
end