require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HashPruner do
  describe "#prune" do
    it "should nil out any repeated hashes" do
      clarke = {:name => "Arthur C. Clarke"}
      heinlein = {:name => "Robert Heinlein"}
      sci_fi = {:name => "Science Fiction", :authors => [clarke, heinlein]}
      clarke[:genre] = sci_fi
      odyssey = {:name => "2001", :genre => sci_fi, :author => clarke}
      hoag = {:name => "the unpleasant profession", :genre => sci_fi, :author => heinlein}
      clarke[:books] = [odyssey]
      heinlein[:books] = [hoag]

      HashPruner.prune(clarke).should == 
        { 
          :name=>"Arthur C. Clarke", 
          :genre => {
            :name => "Science Fiction",
            :authors => [
              {
                :name=>"Robert Heinlein", 
                :books=> [
                  {
                    :name => "the unpleasant profession",
                    :genre => nil, 
                    :author => nil
                  }
                ]
              }
            ]
          },
          :books=> [
            { 
              :name => "2001",
              :genre => {
                :name => "Science Fiction",
                :authors => [
                  {
                    :name=>"Robert Heinlein", 
                    :books=> [
                      {
                        :name => "the unpleasant profession",
                        :genre => nil, 
                        :author => nil
                      }
                    ]
                  }
                ]
              },
              :author => nil 
            }
          ]
        }
    end
  end
end
