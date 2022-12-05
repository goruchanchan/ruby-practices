#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input_data'
require_relative '../lib/ls_file'
require_relative '../lib/ls_directory'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

input_data = InputData.new
input_data.argv_parsing

unless input_data.files.empty?
  puts LsFile.ls(input_data.files, input_data.options, input_data.max_char_length)
end

unless input_data.directories.empty?
  puts unless input_data.files.empty?

  puts LsDirectory.ls(input_data.directories, input_data.options, input_data.max_char_length)
end
