class Dupe
  class Database
    class Record < Hashie::Mash
      attr_accessor :__model__
    end
  end
end