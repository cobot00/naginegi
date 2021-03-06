lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'naginegi/version'

Gem::Specification.new do |spec|
  spec.name          = 'naginegi'
  spec.version       = Naginegi::VERSION
  spec.authors       = ['cobot00']
  spec.email         = ['kobori75@gmail.com']

  spec.summary       = %q{Embulk utility for MySQL and PostgreSQL to BigQuery}
  spec.description   = %q{Generate Embulk config and BigQuery schema from RDBMS schema}
  spec.homepage      = 'https://github.com/cobot00/naginegi'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '2.1.4'
  spec.add_development_dependency 'rake', '12.3.3'
  spec.add_development_dependency 'rspec', '3.8.0'
  spec.add_development_dependency 'rubocop', '0.49.1'
  spec.add_development_dependency 'timecop', '0.9.1'

  spec.add_dependency 'google-cloud-bigquery', '1.18.1'
  spec.add_dependency 'mysql2', '0.5.3'
  spec.add_dependency 'mysql2-cs-bind', '0.0.7'
  spec.add_dependency 'pg', '1.2.2'
  spec.add_dependency 'unindent', '1.0'
end
