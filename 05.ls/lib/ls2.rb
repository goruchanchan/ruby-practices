#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

MAX_COLUMN = 3

def main
  categorize_input_list = argv_parsing # file:引数がファイル, directory:引数がディレクトリ, error:存在しない, option: オプション
  padding_num = search_max_char_length(categorize_input_list)

  print_error_list(categorize_input_list)

  unless categorize_input_list[:file].empty?
    file_list = convert_array_for_print(categorize_input_list[:file])
    print_file_list(file_list, padding_num)
  end

  return if categorize_input_list[:directory].empty?

  puts if !categorize_input_list[:error].empty? || !categorize_input_list[:file].empty?
  directory_file_list = retrieve_hash_list(categorize_input_list[:directory], categorize_input_list[:option])
  directory_file_list = directory_file_list.each { |list| list[:file_list] = convert_array_for_print list[:file_list] }
  print_hash_list(directory_file_list, padding_num)
end

def option_parsing
  opt = OptionParser.new
  opt.on('-a')

  paths = opt.parse(ARGV)
  ARGV - paths
end

def argv_parsing
  file_paths = []
  directory_paths = []
  error_paths = []

  options = option_parsing

  (ARGV - option_parsing).each do |path|
    if FileTest.directory?(path)
      directory_paths.push(path)
    elsif FileTest.file?(path)
      file_paths.push(path)
    else
      error_paths.push(path)
    end
  end

  directory_paths.push('.') if file_paths.empty? && directory_paths.empty? && error_paths.empty?

  { file: file_paths.sort, directory: directory_paths.sort, error: error_paths.sort, option: options.sort }
end

def search_max_char_length(categorize_list)
  if !categorize_list[:file].empty? || !categorize_list[:directory].empty?
    all_file_list = categorize_list[:file] + retrieve_file_list(categorize_list[:directory], categorize_list[:option])
    padding_num = all_file_list.max_by(&:length).length + 1
  end
  padding_num
end

def retrieve_hash_list(search_paths, options)
  if options.include?('-a')
    # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort } }
  else
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', base: path) } }
  end
end

def retrieve_file_list(search_paths, options)
  if options.include?('-a')
    # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
    search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort }
  else
    search_paths.flat_map { |path| Dir.glob('*', base: path) }
  end
end

def convert_array_for_print(lists)
  if lists.length % MAX_COLUMN != 0
    # 行列変換させるために足りない要素にnilをつめていく
    start_fill_nil = lists.length + 1
    end_fill_nil = (((lists.length / MAX_COLUMN) + 1) * MAX_COLUMN - 1)
    column = (lists.length / MAX_COLUMN) + 1
    lists.fill(nil, start_fill_nil..end_fill_nil)
  else
    # 転置してMAX_COLUMN列にするので、sliceではMAX_COLUMN行にする
    column = (lists.length / MAX_COLUMN)
  end

  transpose_paths = []
  lists.each_slice(column) { |split_array| transpose_paths.push(split_array) }
  transpose_paths.transpose
end

def print_error_list(hash_list)
  hash_list[:error].each { |error_path| puts "ls: #{error_path}: No such file or directory" } unless hash_list[:error].empty?
end

def print_hash_list(hash_list, padding_num)
  hash_list.each_with_index do |file_list, i|
    puts "#{file_list[:path]}:" if hash_list.size > 1
    print_file_list(file_list[:file_list], padding_num)
    puts if i < hash_list.length - 1
  end
end

def print_file_list(file_list, padding_num)
  file_list.each do |file_column|
    file_column.each { |file_name| print file_name.to_s.ljust(padding_num) }
    puts
  end
end

main
