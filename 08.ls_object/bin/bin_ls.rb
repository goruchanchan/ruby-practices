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

input_file = InputData.new(files, options)
input_dir = InputData.new(directories, options)

# 最大文字数を更新する
input_file.max_char_length > input_dir.max_char_length ? input_dir.max_char_length = input_file.max_char_length : input_file.max_char_length = input_dir.max_char_length

unless input_file.names.empty?
  ls_file = LsFile.new(input_file)
  puts ls_file.ls
end

# unless input_dir.names.empty?
#   puts unless input_file.names.empty?

#   puts LsDirectory.ls(input_dir.names, input_dir.options, input_dir.max_char_length)
# end
