Gem::Specification.new do |s|
  s.name = "effigy"
  s.version = "0.4.0"

  s.authors = ["Joe Ferris"]
  s.date = %q{2010-08-20}
  s.description = %q{Define views in Ruby and templates in HTML. Avoid code interpolation or ugly templating languages. Use ids, class names, and semantic structures already present in your documents to produce content.}
  s.email = %q{jferris@thoughtbot.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.textile"
  ]
  s.files = Dir['[A-Z]*',
                'lib/**/*.rb',
                'spec/**/*.rb',
                'rails/**/*.rb',
                'generators/**/*.*']
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Effigy provides a view and template framework without a templating language.}
  s.test_files = Dir[*['spec/**/*_spec.rb']]

  s.add_runtime_dependency(%q<nokogiri>, [">= 1.3"])
end

