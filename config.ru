ENV['EMACS_CHROME_EDITOR_PATH'] = '/Users/kayakaya/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'

require 'rubygems'
require 'rack'
if RUBY_VERSION >= '1.9'
  require IO::File.dirname(__FILE__) + "/edit_server"
else
  require File.dirname(__FILE__) + "/edit_server"
end

use Rack::Lint
use Rack::ShowStatus

run EditServer.new
