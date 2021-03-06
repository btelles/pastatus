# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pastatus}
  s.version = ""

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bernie Telles"]
  s.date = %q{2009-11-10}
  s.default_executable = %q{pastatus}
  s.description = %q{Store passenger-status data in a CSV file through the command line}
  s.email = %q{bernardo.telles@dms.myflorida.com}
  s.executables = ["pastatus"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/pastatus",
     "lib/pastatus.rb",
     "lib/pastatus/passenger_log_record.rb",
     "lib/pastatus/passenger_parser.rb",
     "pastatus.gemspec",
     "spec/fixtures/Untitled (35).msg",
     "spec/lib/pastatus_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/btelles/pastatus}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Store passenger-status data in a CSV file through the command line}
  s.test_files = [
    "spec/lib/pastatus_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

