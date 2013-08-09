# Load support
Dir["./spec/support/**/*.rb"].each {|f| require f}

# Load dj_unicorn
require File.expand_path("../../lib/dj_unicorn", __FILE__)