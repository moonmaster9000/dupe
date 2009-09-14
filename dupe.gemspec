# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dupe}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Parker"]
  s.date = %q{2009-09-14}
  s.description = %q{Easily mock ActiveResource responses for testing purposes.}
  s.email = %q{moonmaster9000@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/dupe.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "features/define_resources.feature", "features/find_resources.feature", "features/mock_resources.feature", "features/step_definitions/define_resources.rb", "features/step_definitions/find_resources.rb", "features/step_definitions/mock_resources.rb", "features/support/env.rb", "features/support/hooks.rb", "lib/dupe.rb", "lib/dupe/active_resource.rb", "lib/dupe/attribute.rb", "lib/dupe/configuration.rb", "lib/dupe/cucumber_hooks.rb", "lib/dupe/mock_service_response.rb", "lib/dupe/record.rb", "lib/dupe/dupe.rb", "lib/dupe/sequence.rb", "dupe.gemspec"]
  s.homepage = %q{http://github.com/moonmaster9000/dupe}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Dupe", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dupe}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Easily mock ActiveResource responses for testing purposes.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cucumber>, [">= 0.3.98"])
      s.add_runtime_dependency(%q<activeresource>, [">= 2.3.3"])
    else
      s.add_dependency(%q<cucumber>, [">= 0.3.98"])
      s.add_dependency(%q<activeresource>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<cucumber>, [">= 0.3.98"])
    s.add_dependency(%q<activeresource>, [">= 2.3.3"])
  end
end
