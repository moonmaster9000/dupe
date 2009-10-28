module CustomMocks
  # Maps a service request url to a Dupe find. By default, Dupe will only
  # mock simple requests like SomeResource.find(some_id) or SomeResource.find(:all)
  #
  # For example, suppose you have a Book < ActiveResource::Base class, and
  # somewhere your code does:
  #
  #   Book.find :all, :params => {:limit => 10, :offset => 20}
  #
  # That in turn will send off a request to a url like:
  #
  #   /books.xml?limit=10&offset=20
  #
  # In this file, you could add a "when" statement like:
  #
  #   when %r{/books.xml\?limit=(\d+)&offset=(\d+)$}
  #     start = $2.to_i
  #     finish = start + $1.to_i - 1
  #     Dupe.find(:books)[start..finish]
  def custom_service(url)
    case url

      # remove this and replace it with a real custom mock
      when %r{/bogus_url}
        ''

      else
        raise StandardError.new(
          "There is no custom service mapping for \"#{url}\"." +
          "Now go to features/support/custom_mocks.rb and add it."
        )
    end
  end
end
