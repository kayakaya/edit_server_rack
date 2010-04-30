#
# Copyright (C) 2010, KAYA Satoshi <kayakaya@kayakaya.net>
# You can redistribute it and/or modify it under GPL2.
# This program is inspired from http://blog.monoweb.info/archives/384.
#
#!/usr/bin/env ruby

require 'rubygems'
require 'rack'
require 'tempfile'

class EditServer
  def initialize
     @editor = ENV['EMACS_CHROME_EDITOR_PATH']
  end

  def call(env)
    req = Rack::Request.new(env)
    if req.path_info =~ /edit/
      edit(env)
    else
      status(env)
    end
  end

  def status_and_body_to_response(status, body)
    [status, {'Content-Type' => 'text/plain charset=utf-8'}, [body]]
  end

  def status(env)
    # this status means application status, not http protocol.
    status_and_body_to_response(200, "edit-server is running.\n")
  end

  def edit(env)
    begin
      temp_file = Tempfile.new('editwith_')
      unless env['rack.input'].nil?
        temp_file << StringIO.new(env['rack.input'].read).string
      end
      temp_file.close(false)

      system(@editor, temp_file.path)

      temp_file.open
      edited_str = temp_file.read
      temp_file.close(true)

      status_and_body_to_response(200, edited_str)

    rescue Errno::ENOENT => err
      puts err
      temp_file.close(true)
    rescue IOError => err
      puts err
      status_and_body_to_response(500, 'Internal Server Error')
    end
  end
end
