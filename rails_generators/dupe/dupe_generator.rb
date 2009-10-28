class DupeGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # make sure the features and features/support directories exist
      m.directory 'features/support'

      # copy the custom_mocks.rb example file into features/support
      m.template 'custom_mocks.rb', 'features/support/custom_mocks.rb'

      # copy the dupe_setup.rb example file into features/support
      m.template 'dupe_setup.rb', 'features/support/dupe_setup.rb'
    end
  end
end
