#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input_data'
require_relative '../lib/ls_file'
require_relative '../lib/ls_directory'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

input_data = InputData.new
input_data.argv_parsing

puts LsFile.file_error(input_data.error_list) unless input_data.error_list.empty?

unless input_data.file_list.empty?
  puts unless input_data.error_list.empty?
  puts LsFile.ls(input_data.file_list, input_data.option_list, input_data.max_char_length)
end

unless input_data.directory_list.empty?
  puts unless input_data.file_list.empty? || input_data.error_list.empty?

  puts LsDirectory.ls(input_data.directory_list, input_data.option_list, input_data.max_char_length)
end
