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

  def status(env)
    res = Rack::Response.new
    res.status = 200
    res['Content-Type'] = 'text/plain; charset=utf-8'
    res.write("edit-server is running.\n")
    res.finish
  end

  def edit(env)
    res = Rack::Response.new
    begin
      temp_file = Tempfile.new('editwith_')
      temp_file << StringIO.new(env['rack.input'].read).string
      temp_file.close(false)

      system(@editor, temp_file.path)

      temp_file.open
      edited_str = temp_file.read
      temp_file.close(true)

      res.status = 200
      res['Content-Type'] = 'text/plain; charset=utf-8'
      res.write(edited_str)
      res.finish
    rescue Errno::EXXX => err
      puts err
      temp_file.close(true)
    rescue IOError => err
      res.status = 500
      res['Content-Type'] = 'text/plain; charset=utf-8'
      res.write('Internal Server Error')
      res.finish
      puts err
    end
  end
end
