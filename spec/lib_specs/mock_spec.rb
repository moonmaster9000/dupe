require 'spec_helper'

describe Dupe::Network::Mock do
  before do
    Dupe.reset
  end
  
  describe "new" do
    it "should require the url be a kind of regular expression" do
      proc { Dupe::Network::Mock.new '', proc {} }.should raise_error(
        ArgumentError,
        "The URL pattern parameter must be a type of regular expression."
      )
    end
    
    it "should set the, @url, and @response parameters accordingly" do
      url_pattern = /\//
      response = proc {}
      mock = Dupe::Network::Mock.new url_pattern, response
      mock.url_pattern.should == url_pattern
      mock.response.should == response
    end
  end
  
  describe "match?" do
    it "should determine if a given string matches the mock's url pattern" do
      url = %r{/blogs/(\d+).xml}
      response = proc {}
      mock = Dupe::Network::Mock.new url, response
      mock.match?('/blogs/1.xml').should == true
      mock.match?('/bogs/1.xml').should == false
    end
  end
end

describe Dupe::Network::GetMock do
  describe "using xml" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::XmlFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a Dupe.find with actual results" do
        it "should convert the response result to xml" do
          url_pattern = %r{/books/(\d+)\.xml}
          response = proc {|id| Dupe.find(:book) {|b| b.id == id.to_i}}
          book = Dupe.create :book
          mock = Dupe::Network::GetMock.new url_pattern, response
          mock.mocked_response('/books/1.xml').should == book.to_xml(:root => 'book')

          proc { mock.mocked_response('/books/2.xml') }.should raise_error(Dupe::Network::GetMock::ResourceNotFoundError)

          Dupe.define :author
          mock = Dupe::Network::GetMock.new %r{/authors\.xml$}, proc {Dupe.find :authors}
          mock.mocked_response('/authors.xml').should == [].to_xml(:root => 'results')
        end

        it "should add a request to the Dupe::Network#log" do
          url_pattern = %r{/books/([a-zA-Z0-9-]+)\.xml}
          response = proc {|label| Dupe.find(:book) {|b| b.label == label}}
          book = Dupe.create :book, :label => 'rooby'
          mock = Dupe::Network::GetMock.new url_pattern, response
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/books/rooby.xml')
          Dupe.network.log.requests.length.should == 1
        end
      end

      describe "on a mock object whose response returns nil" do
        it "should raise an error" do
          url_pattern = %r{/authors/(\d+)\.xml}
          response = proc { |id| Dupe.find(:author) {|a| a.id == id.to_i}}
          Dupe.define :author
          mock = Dupe::Network::GetMock.new url_pattern, response
          proc {mock.mocked_response('/authors/1.xml')}.should raise_error(Dupe::Network::GetMock::ResourceNotFoundError)
        end
      end

      describe "on a mock object whose response returns an empty array" do
        it "should convert the empty array to an xml array record set with root 'results'" do        
          Dupe.define :author
          mock = Dupe::Network::GetMock.new %r{/authors\.xml$}, proc {Dupe.find :authors}
          mock.mocked_response('/authors.xml').should == [].to_xml(:root => 'results')
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.define :author
          mock = Dupe::Network::GetMock.new %r{/authors\.xml$}, proc {Dupe.find :authors}
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/authors.xml')
          Dupe.network.log.requests.length.should == 1
        end
      end

      describe "on a mock object whose response returns an array of duped records" do
        it "should convert the array to xml" do        
          Dupe.create :author  
          mock = Dupe::Network::GetMock.new %r{/authors\.xml$}, proc {Dupe.find :authors}
          mock.mocked_response('/authors.xml').should == Dupe.find(:authors).to_xml(:root => 'authors')
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.create :author
          mock = Dupe::Network::GetMock.new %r{/authors\.xml$}, proc {Dupe.find :authors}
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/authors.xml')
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end

  describe "using json" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::JsonFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a Dupe.find with actual results" do
        it "should convert the response result to json" do
          url_pattern = %r{/books/(\d+)\.json}
          response = proc {|id| Dupe.find(:book) {|b| b.id == id.to_i}}
          book = Dupe.create :book
          mock = Dupe::Network::GetMock.new url_pattern, response
          mock.mocked_response('/books/1.json').should == book.to_json(:root => 'book')

          proc { mock.mocked_response('/books/2.json') }.should raise_error(Dupe::Network::GetMock::ResourceNotFoundError)

          Dupe.define :author
          mock = Dupe::Network::GetMock.new %r{/authors\.json$}, proc {Dupe.find :authors}
          mock.mocked_response('/authors.json').should == [].to_json(:root => 'results')
        end

        it "should add a request to the Dupe::Network#log" do
          url_pattern = %r{/books/([a-zA-Z0-9-]+)\.json}
          response = proc {|label| Dupe.find(:book) {|b| b.label == label}}
          book = Dupe.create :book, :label => 'rooby'
          mock = Dupe::Network::GetMock.new url_pattern, response
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/books/rooby.json')
          Dupe.network.log.requests.length.should == 1
        end
      end

      describe "on a mock object whose response returns nil" do
        it "should raise an error" do
          url_pattern = %r{/authors/(\d+)\.json}
          response = proc { |id| Dupe.find(:author) {|a| a.id == id.to_i}}
          Dupe.define :author
          mock = Dupe::Network::GetMock.new url_pattern, response
          proc {mock.mocked_response('/authors/1.json')}.should raise_error(Dupe::Network::GetMock::ResourceNotFoundError)
        end
      end

      describe "on a mock object whose response returns an empty array" do
        it "should convert the empty array to an json array record set with root 'results'" do        
          Dupe.define :author
          mock = Dupe::Network::GetMock.new %r{/authors\.json$}, proc {Dupe.find :authors}
          mock.mocked_response('/authors.json').should == [].to_json(:root => 'results')
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.define :author
          mock = Dupe::Network::GetMock.new %r{/authors\.json$}, proc {Dupe.find :authors}
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/authors.json')
          Dupe.network.log.requests.length.should == 1
        end
      end

      describe "on a mock object whose response returns an array of duped records" do
        it "should convert the array to json" do        
          Dupe.create :author  
          mock = Dupe::Network::GetMock.new %r{/authors\.json$}, proc {Dupe.find :authors}
          mock.mocked_response('/authors.json').should == Dupe.find(:authors).to_json(:root => 'authors')
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.create :author
          mock = Dupe::Network::GetMock.new %r{/authors\.json$}, proc {Dupe.find :authors}
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/authors.json')
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end
end

describe Dupe::Network::PostMock do
  describe "using xml" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::XmlFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a location of a new record" do
        it "should convert the new post to xml" do        
          Dupe.define :author  
          mock = Dupe::Network::PostMock.new %r{/authors\.xml$}, proc {|post_data| Dupe.create(:author, post_data)}
          resp, url = mock.mocked_response('/authors.xml', {:name => "Rachel"})
          resp.should == Dupe.find(:authors).first.make_safe.to_xml(:root => 'author')
          url.should == "/authors/1.xml"
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.define :author
          mock = Dupe::Network::PostMock.new %r{/authors\.xml$}, proc {|post_data| Dupe.create(:author, post_data)}
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/authors.xml', {:name => "Rachel"})
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end

  describe "using json" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::JsonFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a location of a new record" do
        it "should convert the new post to json" do        
          Dupe.define :author  
          mock = Dupe::Network::PostMock.new %r{/authors\.json$}, proc {|post_data| Dupe.create(:author, post_data)}
          resp, url = mock.mocked_response('/authors.json', {:name => "Rachel"})
          resp.should == Dupe.find(:authors).first.make_safe.to_json(:root => 'author')
          url.should == "/authors/1.json"
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.define :author
          mock = Dupe::Network::PostMock.new %r{/authors\.json$}, proc {|post_data| Dupe.create(:author, post_data)}
          Dupe.network.log.requests.length.should == 0
          mock.mocked_response('/authors.json', {:name => "Rachel"})
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end
end

describe Dupe::Network::PutMock do
  describe "using xml" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::XmlFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a location of a new record" do
        before do
          Dupe.define :author  
          @a = Dupe.create :author, :name => "Matt"
          @mock = Dupe::Network::PutMock.new %r{/authors/(\d+)\.xml$}, proc {|id, put_data| Dupe.find(:author) {|a| a.id == id.to_i}.merge!(put_data)}
        end

        it "should convert the put to xml" do        
          resp, url = @mock.mocked_response('/authors/1.xml', {:name => "Rachel"})
          resp.should == nil
          @a.name.should == "Rachel"
          url.should == "/authors/1.xml"
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.network.log.requests.length.should == 0
          @mock.mocked_response('/authors/1.xml', {:name => "Rachel"})
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end

  describe "using json" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::JsonFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a location of a new record" do
        before do
          Dupe.define :author  
          @a = Dupe.create :author, :name => "Matt"
          @mock = Dupe::Network::PutMock.new %r{/authors/(\d+)\.json$}, proc {|id, put_data| Dupe.find(:author) {|a| a.id == id.to_i}.merge!(put_data)}
        end

        it "should convert the put to json" do        
          resp, url = @mock.mocked_response('/authors/1.json', {:name => "Rachel"})
          resp.should == nil
          @a.name.should == "Rachel"
          url.should == "/authors/1.json"
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.network.log.requests.length.should == 0
          @mock.mocked_response('/authors/1.json', {:name => "Rachel"})
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end
end

describe Dupe::Network::DeleteMock do
  describe "using xml" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::XmlFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a location of a new record" do
        before do
          Dupe.define :author  
          @a = Dupe.create :author, :name => "Matt"
          @mock = Dupe::Network::DeleteMock.new %r{/authors/(\d+)\.xml$}, proc {|id| Dupe.delete(:author) {|a| a.id == id.to_i}}
        end

        it "should convert the put to xml" do        
          Dupe.find(:authors).length.should == 1
          resp = @mock.mocked_response('/authors/1.xml')
          resp.should == nil
          Dupe.find(:authors).length.should == 0
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.network.log.requests.length.should == 0
          @mock.mocked_response('/authors/1.xml')
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end

  describe "using json" do
    before do
      Dupe.reset
      Dupe.format = ActiveResource::Formats::JsonFormat
    end

    describe "mocked_response" do
      describe "on a mock object whose response returns a location of a new record" do
        before do
          Dupe.define :author  
          @a = Dupe.create :author, :name => "Matt"
          @mock = Dupe::Network::DeleteMock.new %r{/authors/(\d+)\.json$}, proc {|id| Dupe.delete(:author) {|a| a.id == id.to_i}}
        end

        it "should convert the put to json" do        
          Dupe.find(:authors).length.should == 1
          resp = @mock.mocked_response('/authors/1.json')
          resp.should == nil
          Dupe.find(:authors).length.should == 0
        end

        it "should add a request to the Dupe::Network#log" do
          Dupe.network.log.requests.length.should == 0
          @mock.mocked_response('/authors/1.json')
          Dupe.network.log.requests.length.should == 1
        end
      end
    end
  end
end
