class Dupe 
  class MockServiceResponse #:nodoc:
    attr_reader :mocks
    attr_reader :resource_name
    attr_reader :format

    def initialize(resource_name, format=:xml)
      @mocks = []
      @resource_name = resource_name
      @to_format = "to_#{format}"
    end
    
    def define_mock(prock)
      @mocks << prock
    end

    def method_missing(method_name, *args, &block)
      @mocks << block
    end

    def run_mocks(records, identifiers)
      ActiveResource::HttpMock.respond_to do |mock|
        @mocks.each do |a_mock|
          a_mock.call mock, records
        end
      end
      find_all(records)
      records.each {|r| find_one(r, identifiers)}
    end
    
    
    private
    def find_all(records)
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/#{@resource_name.to_s.pluralize}.xml",  {}, format_for_service_response(records)
      end
    end
    
    def find_one(record, identifiers)
      ActiveResource::HttpMock.respond_to do |mock|
        identifiers.each do |identifier|
          mock.get "/#{@resource_name.to_s.pluralize}/#{record[identifier]}.xml", {}, format_for_service_response(record)
        end
      end
    end

    def format_for_service_response(records)
      root = (records.is_a? Array) ? @resource_name.to_s.pluralize : @resource_name.to_s
      @format == :json ? records.to_json({:root => root}): records.to_xml({:root => root})
    end
  end
end
