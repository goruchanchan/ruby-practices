#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/ls'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

def retrieve_hash_list(search_paths, options)
  if options.include?('-a')
    # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort_by(&:to_s) } }
  else
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', base: path) } }
  end
end

def parsing_reverse_hash_list(hash_list, options)
  if options.include?('-r')
    # ".."がsortメソッドでうまくソートされなかったので、sort_byでString型にしてソートする
    hash_list.reverse.map { |hash| { path: hash[:path], file_list: hash[:file_list].sort_by(&:to_s).reverse } }
  else
    hash_list
  end
end

def max_char_length(file_list)
  file_list.empty? ? 0 : file_list.max_by(&:length).length + 1
end

def retrieve_file_list(search_paths, options)
  if options.include?('-a')
    # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
    search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
  else
    search_paths.flat_map { |path| Dir.glob('*', base: path) }
  end
end

categorize_input_list = argv_parsing

error_list = categorize_input_list[:error]
option_list = categorize_input_list[:option]
file_list = categorize_input_list[:file]
directory_list = categorize_input_list[:directory]

puts error_message(error_list) unless error_list.empty?

all_file_list = file_list + retrieve_file_list(directory_list, option_list)
padding = max_char_length(all_file_list)

unless file_list.empty?
  puts unless error_list.empty?

  file_list = file_list.reverse if option_list.include?('-r')

  puts ls_files(file_list, option_list, padding)
end

unless directory_list.empty?
  puts unless file_list.empty?

  directory_files = retrieve_hash_list(categorize_input_list[:directory], option_list)
  directory_files = parsing_reverse_hash_list(directory_files, option_list)
  print_directories(directory_files, option_list, padding)
end
