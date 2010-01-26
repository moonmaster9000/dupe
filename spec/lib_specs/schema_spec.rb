require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Model::Schema do
  describe "new" do
    it "should initialize attribute_templates to an empty hash" do
      Dupe::Model::Schema.new.attribute_templates.should == {}
    end
    
    it "should initialize after_create_callbacks to an empty array" do
      Dupe::Model::Schema.new.after_create_callbacks.should == []
    end
  end
  
  describe "dynamic attribute_template creation methods" do
    before do
      @schema = Dupe::Model::Schema.new
    end
    
    describe "called with no parameters" do
      it "should create a new attribute template with no transformer and no default value" do
        @schema.title
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should be_nil
        @schema.attribute_templates[:title].transformer.should be_nil
      end
    end
    
    describe "called with a single parameter, but no block" do
      it "should create a new attribute template with a default value but no transformer" do
        @schema.title 'Untitled'
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should == 'Untitled'
        @schema.attribute_templates[:title].transformer.should be_nil
      end
    end
    
    describe "called with a block that accepts a parameter" do
      it "should create a new attribute template without a default value, but with a tranformer" do
        @schema.title {|dont_care| 'test'}
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should be_nil
        @schema.attribute_templates[:title].transformer.should be_kind_of(Proc)
      end
    end
    
    describe "called with a block that doesn't accept a parameter" do
      it "should create a new attribute template without a transformer, and with the block as the default value" do
        @schema.title { 'knock' * 3 }
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should be_kind_of(Proc)
        @schema.attribute_templates[:title].default.call.should == "knockknockknock"
        @schema.attribute_templates[:title].transformer.should be_nil
      end
    end
    
    describe "called with a block and a parameter" do
      it "should create a new attribute template with a default value AND with a tranformer" do
        @schema.title('Untitled') {|dont_care| 'test'}
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should == 'Untitled'
        @schema.attribute_templates[:title].transformer.should be_kind_of(Proc)
      end
    end
  end
  
  describe "#after_create" do
    before do
      @schema = Dupe::Model::Schema.new
    end
    
    it "should require a block that accepts a single parameter" do
      proc { @schema.after_create }.should raise_error(ArgumentError)
      proc { @schema.after_create { "parameterless block" } }.should raise_error(ArgumentError)
      proc { @schema.after_create {|s| s.title = 'test' } }.should_not raise_error
    end
    
    it "should add the callback to the list of after_create_callbacks" do
      @schema.after_create_callbacks.should be_empty
      @schema.after_create {|s| s.title = 'test'}
      @schema.after_create_callbacks.length.should == 1
      @schema.after_create_callbacks.first.should be_kind_of(Proc)
    end
    
  end

  describe "#uniquify" do
    before do
      @schema = Dupe::Model::Schema.new
    end

    it "should only accept a list of symbols" do
      proc { @schema.uniquify }.should raise_error(ArgumentError, "You must pass at least one attribute to uniquify.")
      proc { @schema.uniquify :hash => 'value' }.should raise_error(ArgumentError, "You may only pass symbols to uniquify.")
      proc { @schema.uniquify :one, :two}.should_not raise_error
    end

    it "should create after_create_callbacks for each symbol passed to it" do
      @schema.after_create_callbacks.should be_empty
      @schema.uniquify :title, :label
      @schema.after_create_callbacks.length.should == 2
      @schema.after_create_callbacks.first.should be_kind_of(Proc)
    end
  end
end
