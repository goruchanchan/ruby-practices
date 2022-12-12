#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input_data'
require_relative '../lib/ls_file'
require_relative '../lib/ls_directory'

require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-a') { |v| options[:all] = v }
opt.on('-r') { |v| options[:reverse] = v }
opt.on('-l') { |v| options[:long] = v }
opt.parse!(ARGV)

input = Input.new(paths: ARGV, option_all: options[:all], option_long: options[:long], option_reverse: options[:reverse])
input
#puts LsFile.new(input.files).ls unless input_file.names.empty?

# unless input_dir.names.empty?
#   puts unless input_file.names.empty?

#   puts LsDirectory.new(input_dir).ls
# end
