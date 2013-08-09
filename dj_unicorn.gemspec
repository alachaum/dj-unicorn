Gem::Specification.new do |spec|
  #spec.add_dependency   'activesupport', ['>= 3.0', '< 4.1']
  spec.authors        = ["Arnaud Lachaume"]
  spec.description    = "Manage Delayed::Job the unicorn way"
  spec.email          = ['arnaud.lachaume@maestrano.com']
  spec.files          = %w(LICENSE.md README.md Rakefile dj_unicorn.gemspec)
  spec.files         += Dir.glob('{lib,spec}/**/*')
  spec.homepage       = 'http://github.com/alachaum/dj-unicorn'
  spec.licenses       = ['GPLv2']
  spec.name           = 'dj-unicorn'
  spec.require_paths  = ['lib']
  spec.summary        = 'Manage Delayed::Job the unicorn way'
  spec.test_files     = Dir.glob('spec/**/*')
  spec.version        = '0.0.1'
end