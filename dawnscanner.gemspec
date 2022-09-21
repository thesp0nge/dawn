# -*- encoding: utf-8 -*-
require_relative 'lib/dawn/version'

Gem::Specification.new do |gem|
  gem.name          = "dawnscanner"
  gem.version       = Dawn::VERSION
  gem.authors       = ["Paolo Perego"]
  gem.email         = ["paolo@dawnscanner.org"]
  gem.description   = %q{Dawnscanner is a security source code scanner for ruby powered code. It is especially designed for web applications, but it works also with general purpose ruby scripts. Dawn supports all major MVC frameworks like ruby on rails, padrino and sinatra; it provides more than 150 security checks with their own mitigation suggestion.}
  gem.summary       = %q{Dawnscanner is a security source code scanner for ruby powered code. It is crafted with love to make your sinatra, padrino and ruby on rails web applications secure.}
  gem.homepage      = "https://dawnscanner.org"
  gem.files         = `git ls-files`.split($/)
  gem.license       = "MIT"
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.3.0'

  gem.add_dependency 'cvss'
  gem.add_dependency 'haml'
  gem.add_dependency 'ruby_parser'
  gem.add_dependency 'sys-uname'
  gem.add_dependency 'terminal-table'
  gem.add_dependency 'justify'
  gem.add_dependency 'logger-colors'
  gem.add_dependency 'ptools'
  gem.add_dependency 'psych'

  # For CLI we will use thor
  gem.add_dependency 'thor'

  # gem.add_dependency 'sqlite3'
  # gem.add_dependency 'datamapper'
  # gem.add_dependency 'dm-sqlite-adapter'

  # To be added back in 1.5.5
  # gem.add_dependency 'code_metrics'
  # gem.add_dependency 'metric_fu-Saikuro'
  # gem.add_dependency 'flay'
  # gem.add_dependency 'churn'
  # gem.add_dependency 'flog'
  # gem.add_dependency 'reek'
  # gem.add_dependency 'cane'

  # This gem is used to extract info from a git archives. This feature will be
  # available in dawnscanner 2.0.0. Disabling the dependency right now.
  # gem.add_dependency 'grit'

  # Marked to be unused right now
  # gem.add_dependency 'parser'

  gem.add_development_dependency ('coveralls')
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency('tomdoc')
  gem.add_development_dependency('aruba')
  gem.add_development_dependency('simplecov')
end
