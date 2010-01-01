class DupeGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # make sure the features and features/support directories exist
      m.directory 'features/support'
      m.directory 'features/dupe'
      m.directory 'features/dupe/custom_mocks'
      m.directory 'features/dupe/definitions'

      # copy the custom_mocks.rb example file into features/dupe/custom_mocks
      m.template 'custom_mocks.rb', 'features/dupe/custom_mocks/custom_mocks.rb'

      # copy the definitions.rb example file into features/dupe/definitions
      m.template 'definitions.rb', 'features/dupe/definitions/definitions.rb'
      
      # copy the load_dupe.rb into the features/support directory
      m.template 'load_dupe.rb', 'features/support/load_dupe.rb'
    end
  end
end
