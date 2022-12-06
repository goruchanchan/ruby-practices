#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input_data'
require_relative '../lib/ls_file'
require_relative '../lib/ls_directory'

require 'optparse'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

options = {}
opt = OptionParser.new
opt.on('-a') { |v| options[:a] = v }
opt.on('-r') { |v| options[:r] = v }
opt.on('-l') { |v| options[:l] = v }
opt.parse!(ARGV)

files = []
directories = []
ARGV.each do |path|
  if FileTest.directory?(path)
    directories.push(path)
  else
    files.push(path)
  end
end
directories.push('.') if files.empty? && directories.empty?

input = InputData.new(files, directories, options)

puts LsFile.ls(input.files, input.options, input.max_char_length) unless input.files.empty?

unless input.directories.empty?
  puts unless input.files.empty?

  puts LsDirectory.ls(input.directories, input.options, input.max_char_length)
end
