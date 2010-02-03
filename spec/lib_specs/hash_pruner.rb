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
                :name=>"Arthur C. Clarke"
              },
              {
                :name=>"Robert Heinlein", 
                :books=> [
                  {
                    :name => "the unpleasant profession",
                    :genre => {
                      :name => "Science Fiction"
                    }, 
                    :author => {
                      :name => "Robert Heinlein"
                    }
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
                    :name => "Arthur C. Clarke"                    
                  },
                  {
                    :name=>"Robert Heinlein", 
                    :books=> [
                      {
                        :name => "the unpleasant profession",
                        :genre => {
                          :name => "Science Fiction"
                        }, 
                        :author => {
                          :name => "Robert Heinlein"
                        }
                      }
                    ]
                  }
                ]
              },
              :author => {
                :name => "Arthur C. Clarke"
              } 
            }
          ]
        }
    end
  end
end
