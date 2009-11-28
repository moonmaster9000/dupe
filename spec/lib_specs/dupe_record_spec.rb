require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Dupe::Record" do
  describe "the new method" do
    it "should setup an empty internal hash when created with no parameters" do
      r = Dupe::Record.new
      r.internal_attributes_hash.should == {}
    end
    
    it "should be accessible via missing methods" do
      book = Dupe::Record.new :title => 'Bible', :author => {:name => 'Jebus'}
      book.title.should == 'Bible'
      book.author.name.should == 'Jebus'
    end
    
    it "should be accessible via hash accessors" do
      book = Dupe::Record.new :title => 'Bible', :author => {:name => 'Jebus'}
      book[:title].should == 'Bible'
      book[:author][:name].should == 'Jebus'
    end
    
    it "should let you set attributes via method missing" do
      book = Dupe::Record.new :title => 'Bible', :author => {:name => 'Jebus'}
      book.genre = 'Superstition'
      book.genre.should == 'Superstition'
      book.chapters = [
        {:title => 'Hair', :start => 1},
        {:title => 'Carpet', :start => 15}
      ]
      book.chapters.first.title.should == 'Hair'
      book.chapters.first.start.should == 1
      book.chapters.last.title.should == 'Carpet'
      book.chapters.last.start.should == 15
    end
    
    it "should let you set attributes via has accessors" do
      book = Dupe::Record.new :title => 'Bible', :author => {:name => 'Jebus'}
      
      # setting existing attributes
      book[:title] = 'The Carpet Makers'
      book[:author][:name] = 'Andreas Eschbach'
      book[:title].should == 'The Carpet Makers'
      book[:author][:name].should == 'Andreas Eschbach'
      
      # setting new attributes
      book[:genre] = 'Science Fiction'
      book[:genre].should == 'Science Fiction'
      
      # setting hash attributes
      book[:chapters] = [
        {:title => 'Hair', :start => 1},
        {:title => 'Carpet', :start => 15}
      ]
      book[:chapters][0][:title].should == 'Hair'
    end
  end
end