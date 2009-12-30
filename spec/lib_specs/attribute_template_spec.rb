require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Model::Schema::AttributeTemplate do 
  describe "new" do
    it "should require a name" do
      proc {
        Dupe::Model::Schema::AttributeTemplate.new
      }.should raise_error(ArgumentError)
    end
    
    it "should set the name if one is passed to it" do
      attribute = Dupe::Model::Schema::AttributeTemplate.new(:title)
      attribute.name.should == :title
    end
    
    it "should set a default value if one is passed to it" do
      attribute = 
        Dupe::Model::Schema::AttributeTemplate.new(
          :title, 
          :default => 'Untitled'
        )
      attribute.default.should == 'Untitled'
    end
    
    it "should verify that the transformer is a proc" do
      proc {
        attribute = 
          Dupe::Model::Schema::AttributeTemplate.new(
            :title, 
            :default => nil, 
            :transformer => 'not a proc'
          )
      }.should raise_error(
        ArgumentError,
        "Your transformer must be a kind of proc."
      )
    end
    
    it "should verify that the transformer requires a single parameter" do
      proc {
        attribute = Dupe::Model::Schema::AttributeTemplate.new(
          :title, 
          :default => nil, 
          :transformer => proc {'test'}
        )
      }.should raise_error(
        ArgumentError,
        "Your transformer must accept a parameter."
      )
    end
    
    it "should set the transformer if one is passed" do
      transformer = proc {|dont_care| }
      attribute = Dupe::Model::Schema::AttributeTemplate.new(
        :title, 
        :default => nil, 
        :transformer => transformer
      )
      attribute.transformer.should == transformer
    end
  end
  
  describe "generate" do
    describe "on an attribute without a default value and without a transformer" do
      before do
        @attribute = Dupe::Model::Schema::AttributeTemplate.new(:title)
      end

      it "should generate a key with the name of the attribute" do
        key, value = @attribute.generate
        key.should == @attribute.name
      end
      
      describe "when passed nothing" do     
        it "should generate a nil value" do
          key, value = @attribute.generate
          value.should == nil
        end
      end
      
      describe "when passed a value" do
        it "should generate a value equal to the value passed in" do
          key, value = @attribute.generate('test')
          value.should == 'test'
        end
      end
    end
    
    describe "on an attribute with a default value but without a transformer" do
      before do
        @attribute = Dupe::Model::Schema::AttributeTemplate.new(:title, :default => 'Untitled')
      end

      it "should generate a key with the name of the attribute" do
        key, value = @attribute.generate
        key.should == @attribute.name
      end   
      
      describe "when passed nothing" do
        it "should generate a value equal to the default value" do
          key, value = @attribute.generate
          value.should == @attribute.default
        end
      end
      
      describe "when passed a value" do
        it "should generate a value equal to the value passed in" do
          title = '2001: A Space Odyssey'
          key, value = @attribute.generate title
          value.should == title
        end
      end
    end
    
    describe "on an attribute with a default value that is a proc" do
      before do
        @default_value = proc { 'knock' * 3 }
        @attribute = Dupe::Model::Schema::AttributeTemplate.new(:title, :default => @default_value)
      end

      it "should generate a key with the name of the attribute" do
        key, value = @attribute.generate
        key.should == @attribute.name
      end   
      
      describe "when passed nothing" do
        it "should return the value of the default_value proc" do
          key, value = @attribute.generate
          value.should == @default_value.call
        end
      end
      
      describe "when passed a value" do
        it "should generate a value equal to the value passed in" do
          title = 'Rooby'
          key, value = @attribute.generate title
          value.should == title
        end
      end
      
    end
    
    describe "on an attribute with a transformer" do
      before do
        @transformer = proc {|dont_care| 'test'}
        @attribute = Dupe::Model::Schema::AttributeTemplate.new(
          :title, 
          :default => nil, 
          :transformer => @transformer
        )
      end
      
      it "should generate a key with the name of the attribute" do
        key, value = @attribute.generate
        key.should == @attribute.name
      end
      
      describe "when passed nothing" do
        it "should generate a value equal to the default" do
          key, value = @attribute.generate
          value.should == @attribute.default
        end
      end
      
      describe "when passed a value" do
        it "should generate a value equal to the value returned by the transformer" do
          key, value = @attribute.generate 'blah'
          value.should == @transformer.call('blah')
        end
      end
    end
  end
end