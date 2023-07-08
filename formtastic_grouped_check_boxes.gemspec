# frozen_string_literal: true

# https://guides.rubygems.org/name-your-gem/
# https://bundler.io/guides/creating_gem.html
# https://guides.rubyonrails.org/engines.html
# https://guides.rubyonrails.org/plugins.html

require_relative "lib/formtastic_grouped_check_boxes/version"

Gem::Specification.new do |spec|
  spec.name             = "formtastic_grouped_check_boxes"
  spec.version          =  FormtasticGroupedCheckBoxes::VERSION
  spec.authors          = ["Sergey Pedan"]
  spec.email            = ["sergey.pedan@gmail.com"]
  spec.license          =  "MIT"

  spec.summary          =  "..."
  spec.description      = <<~HEREDOC
                            #{spec.summary}. This gem:
                          HEREDOC

  spec.homepage         =  "https://github.com/sergeypedan/formtastic-grouped-checkboxes"
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md"]
  spec.rdoc_options     = ["--charset=UTF-8"]
  spec.metadata         = { "changelog_uri"     => "#{spec.homepage}/blob/master/CHANGELOG.md",
                            "documentation_uri" => "https://www.rubydoc.info/gems/#{spec.name}",
                            "homepage_uri"      => spec.homepage,
                            "source_code_uri"   => spec.homepage }

  spec.require_paths    = ["app/inputs", "lib"]
  spec.bindir           = "exe"
  spec.executables      = []
  spec.files            = Dir.chdir(File.expand_path(__dir__)) do
                            `git ls-files`.split("\n")
                              .reject { |f| %w[bin spec test].any? { |dir| f.start_with? dir } }
                              .reject { |f| f.start_with? "." }
                          end

  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "formtastic", ">= 3", "< 5"
  spec.add_dependency "rails",      ">= 4", "< 10"

  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "yard",  ">= 0.9.20", "< 1"
end
