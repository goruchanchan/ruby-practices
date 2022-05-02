#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'optparse'

require './lib/wc_command'

params = { l_option: false}

opt = OptionParser.new
opt.on('-l') { |v| params[:l_option] = v }
opt.parse!(ARGV)

if ARGV.empty?
  puts run_wc(sentence: $stdin.read, **params)
else
  ARGV.each do |file_path|
    pathname = Pathname(file_path)
    if FileTest.exist?(file_path)
      puts run_wc(file_path: pathname, sentence: File.open(file_path).read, **params) 
    else
      puts run_wc(file_path: pathname, sentence: nil)
    end
  end
  puts get_total_size(params) if ARGV.size > 1
end
