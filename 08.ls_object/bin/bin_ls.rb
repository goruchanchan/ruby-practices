#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/argv_parser'
require_relative '../lib/ls'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

def main
  categorize_input_list = argv_parsing # file:引数がファイル, directory:引数がディレクトリ, error:存在しない, option: オプション

  print_error_list(categorize_input_list[:error])

  unless categorize_input_list[:file].empty?
    file_list = parsing_reverse_file_list(categorize_input_list[:file], categorize_input_list[:option])
    print_files(file_list, categorize_input_list)
  end

  return if categorize_input_list[:directory].empty?

  puts if !categorize_input_list[:error].empty? || !categorize_input_list[:file].empty?
  directory_file_list = retrieve_hash_list(categorize_input_list[:directory], categorize_input_list[:option])
  directory_file_list = parsing_reverse_hash_list(directory_file_list, categorize_input_list[:option])
  print_directories(directory_file_list, categorize_input_list)
end

main
