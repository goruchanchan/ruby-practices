#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input_data'
require_relative '../lib/ls_file'
require_relative '../lib/ls_directory'

require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-a') { |v| options[:a] = v }
opt.on('-r') { |v| options[:r] = v }
opt.on('-l') { |v| options[:l] = v }
opt.parse!(ARGV)

files = []
directories = []
ARGV.each do |path|
  FileTest.directory?(path) ? directories.push(path) : files.push(path)
end
directories.push('.') if files.empty? && directories.empty?

input_file = InputData.new(files, options)
input_dir = InputData.new(directories, options)

# 最大文字数を更新する
if input_file.max_char_length > input_dir.max_char_length
  input_dir.max_char_length = input_file.max_char_length
else
  input_file.max_char_length = input_dir.max_char_length
end

puts LsFile.new(input_file).ls unless input_file.names.empty?

unless input_dir.names.empty?
  puts unless input_file.names.empty?

  puts LsDirectory.new(input_dir).ls
end
