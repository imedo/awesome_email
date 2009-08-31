# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{awesome_email}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["imedo GmbH"]
  s.date = %q{2009-08-31}
  s.description = %q{Rails ActionMailer with HTML layouts, inline CSS and entity substitution.}
  s.email = %q{entwickler@imedo.de}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "MIT-LICENSE",
     "README.textile",
     "Rakefile",
     "lib/awesome_email.rb",
     "lib/awesome_email/convert_entities.rb",
     "lib/awesome_email/helpers.rb",
     "lib/awesome_email/inline_styles.rb",
     "lib/awesome_email/layouts.rb",
     "rails/init.rb",
     "test/awesome_email_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/grimen/awesome_email/tree/master}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rails ActionMailer with HTML layouts, inline CSS and entity substitution.}
  s.test_files = [
    "test/awesome_email_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
