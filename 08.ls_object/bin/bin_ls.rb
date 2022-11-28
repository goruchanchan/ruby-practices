#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/all_data'
require_relative '../lib/ls_file'
require_relative '../lib/ls_directory'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

all_data = AllData.new
all_data.argv_parsing

puts LsFile.error_message(all_data.error_list) unless all_data.error_list.empty?

unless all_data.file_list.empty?
  puts unless all_data.error_list.empty?
  puts LsFile.ls_files(all_data.file_list, all_data.option_list, all_data.max_char_length)
end

unless all_data.directory_list.empty?
  puts unless all_data.file_list.empty? || all_data.error_list.empty?

  puts LsDirectory.ls_directories(all_data.directory_list, all_data.option_list, all_data.max_char_length)
end
