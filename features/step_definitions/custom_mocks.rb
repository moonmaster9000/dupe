When /^I define a custom `count` mock for "([^"]+)"$/ do |resource|
  eval <<-EOE
    module CustomMocks
      def custom_service(url)
        case url
          when %r{/#{resource}/count.xml}
            {:count => Dupe.find(:books).size}.to_xml
          else
            raise StandardError.new(%{There is no custom service mapping for #{resource} service "\#{url}". Now go to features/support/custom_mocks.rb and add it.})
        end
      end
    end
  EOE
end

When /^I define a custom mock for retreiving books written by a particular author$/ do
  module CustomMocks
    def custom_service(url)
      case url
        when %r{^/books\.xml\?author_id=([^&]*)$}
          Dupe.find(:books) {|b| b.author.label == $1 }
        else
          raise StandardError.new(%{There is no custom service mapping for "#{url}". Now go to features/support/custom_mocks.rb and add it.})
      end
    end
  end
end
