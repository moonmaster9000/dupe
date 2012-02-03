require 'spec_helper'

describe ActiveResource::Connection do
  before do
    Dupe.reset
  end

  describe "#get" do
    before do
      @book = Dupe.create :book, :title => 'Rooby', :label => 'rooby'
      class Book < ActiveResource::Base
        self.site   = 'http://www.example.com'
        self.format = :xml
      end
    end

    it "should pass a request off to the Dupe network if the original request failed" do
      Dupe.network.should_receive(:request).with(:get, '/books.xml').once.and_return(Dupe.find(:books).to_xml(:root => 'books'))
      books = Book.find(:all)
    end

    it "should parse the xml and turn the result into active resource objects" do
      books = Book.find(:all)
      books.length.should == 1
      books.first.id.should == 1
      books.first.title.should == 'Rooby'
      books.first.label.should == 'rooby'
    end
  end

  describe "#post" do
    before do
      @book = Dupe.create :book, :label => 'rooby', :title => 'Rooby'
      @book.delete(:id)
      class Book < ActiveResource::Base
        self.site = 'http://www.example.com'
      end
    end

    it "should pass a request off to the Dupe network if the original request failed" do
      Dupe.network.should_receive(:request).with(:post, '/books.xml', Hash.from_xml(@book.to_xml(:root => 'book'))["book"] ).once
      book = Book.create({:label => 'rooby', :title => 'Rooby'})
    end

    it "should parse the xml and turn the result into active resource objects" do
      book = Book.create({:label => 'rooby', :title => 'Rooby'})
      book.id.should == 2
      book.title.should == 'Rooby'
      book.label.should == 'rooby'
    end

    it "should make ActiveResource throw an unprocessable entity exception if our Post mock throws a Dupe::UnprocessableEntity exception" do
      Post %r{/books\.xml} do |post_data|
        raise Dupe::UnprocessableEntity.new(:title => "must be present.") unless post_data["title"]
        Dupe.create :book, post_data
      end

      b = Book.create
      b.new?.should be_true
      b.errors.should_not be_empty
      b = Book.create(:title => "hello")
      b.new?.should be_false
      b.errors.should be_empty
    end

    it "should handle request with blank body" do
      class SubscribableBook < ActiveResource::Base
        self.site = 'http://www.example.com'
        self.format = :xml

        def self.send_update_emails
          post(:send_update_emails)
        end
      end

      Post %r{/subscribable_books/send_update_emails\.xml} do |post_data|
        Dupe.create :email, post_data
      end

      response = SubscribableBook.send_update_emails
      response.code.should == 201
    end
  end

  describe "#put" do
    before do
      @book = Dupe.create :book, :label => 'rooby', :title => 'Rooby'
      class Book < ActiveResource::Base
        self.site = 'http://www.example.com'
      end
      @ar_book = Book.find(1)
    end

    it "should pass a request off to the Dupe network if the original request failed" do
      Dupe.network.should_receive(:request).with(:put, '/books/1.xml', Hash.from_xml(@book.merge(:title => "Rails!").to_xml(:root => 'book'))["book"].symbolize_keys!).once.and_return([nil, '/books/1.xml'])
      @ar_book.title = 'Rails!'
      @ar_book.save
    end

    context "put methods that return HTTP 204" do
      before(:each) do
        class ExpirableBook < ActiveResource::Base
          self.site   = 'http://www.example.com'
          self.format = :xml
          attr_accessor :state

          def expire_copyrights!
            put(:expire)
          end
        end

        Put %r{/expirable_books/(\d)+/expire.xml} do |id, body|
          Dupe.find(:expirable_book) { |eb| eb.id == id.to_i }.tap { |book|
            book.state = 'expired'
          }
        end

        @e = Dupe.create :expirable_book, :title => 'Impermanence', :state => 'active'
      end

      it "should handle no-content responses" do
        response = ExpirableBook.find(@e.id).expire_copyrights!
        response.body.should be_blank
        response.code.to_s.should == "204"
      end
    end

    it "should parse the xml and turn the result into active resource objects" do
      @book.title.should == "Rooby"
      @ar_book.title = "Rails!"
      @ar_book.save
      @ar_book.new?.should == false
      @ar_book.valid?.should == true
      @ar_book.id.should == 1
      @ar_book.label.should == "rooby"
      @book.title.should == "Rails!"
      @book.id.should == 1
      @book.label.should == 'rooby'
    end

    it "should make ActiveResource throw an unprocessable entity exception if our Put mock throws a Dupe::UnprocessableEntity exception" do
      Put %r{/books/(\d+)\.xml} do |id, put_data|
        raise Dupe::UnprocessableEntity.new(:title => " must be present.") unless put_data[:title]
        Dupe.find(:book) {|b| b.id == id.to_i}.merge!(put_data)
      end

      @ar_book.title = nil
      @ar_book.save.should == false
      @ar_book.errors[:base].should_not be_empty

      @ar_book.title = "Rails!"
      @ar_book.save.should == true
      # the following line should be true, were it not for a bug in active_resource 2.3.3 - 2.3.5
      # i reported the bug here: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4169-activeresourcebasesave-put-doesnt-clear-out-errors
      # @ar_book.errors.should be_empty
    end
  end

  describe "#delete" do
    before do
      @book = Dupe.create :book, :label => 'rooby', :title => 'Rooby'
      class Book < ActiveResource::Base
        self.site   = 'http://www.example.com'
        self.format = :xml
      end
      @ar_book = Book.find(1)
    end

    it "should pass a request off to the Dupe network if the original request failed" do
      Dupe.network.should_receive(:request).with(:delete, '/books/1.xml').once
      @ar_book.destroy
    end

    it "trigger a Dupe.delete to delete the mocked resource from the duped database" do
      Dupe.find(:books).length.should == 1
      @ar_book.destroy
      Dupe.find(:books).length.should == 0
    end

    it "should allow you to override the default DELETE intercept mock" do
      Delete %r{/books/(\d+)\.xml} do |id|
        raise StandardError, "Testing Delete override"
      end

      proc {@ar_book.destroy}.should raise_error(StandardError, "Testing Delete override")
    end
  end

end
