#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'matrix'

# オプションの指定はコマンド直後にしたいので環境変数を設定しておく
ENV['POSIXLY_CORRECT'] = '1'

# 配列の順番と権限を組み合わせてみました
PERMISSION_ARRAY = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

MAX_COLUMN = 3

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

def option_parsing
  opt = OptionParser.new
  opt.on('-a')
  opt.on('-r')
  opt.on('-l')

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
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort_by(&:to_s) } }
  else
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', base: path) } }
  end
end

def retrieve_file_list(search_paths, options)
  if options.include?('-a')
    # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
    search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
  else
    search_paths.flat_map { |path| Dir.glob('*', base: path) }
  end
end

def parsing_reverse_file_list(file_list, options)
  if options.include?('-r')
    file_list.reverse
  else
    file_list
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

def print_error_list(error_list)
  error_list.each { |error_path| puts "ls: #{error_path}: No such file or directory" } unless error_list.empty?
end

def print_hash_list(input_hash_list, padding_num)
  input_hash_list.each_with_index do |file_list, i|
    puts "#{file_list[:path]}:" if input_hash_list.size > 1
    print_file_list(file_list[:file_list], padding_num)
    puts if i < input_hash_list.length - 1
  end
end

def print_file_list(input_file_list, padding_num)
  input_file_list.each do |file_column|
    file_column.each { |file_name| print file_name.to_s.ljust(padding_num) }
    puts
  end
end

def convert_list_segment(file_list, path)
  file_list.map { |file| construct_list_segment(file, path) }
end

def calculate_block_size(file_list, path)
  file_list.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
end

def print_files(file_list, categorize_input_list)
  if categorize_input_list[:option].include?('-l')
    file_list = convert_list_segment(file_list, '.')
    padding_list = (0..6).map { |n| Matrix.columns(file_list).row(n).max.to_s.length }
    print_list_segment(file_list, padding_list)
  else
    file_list = convert_array_for_print(file_list)
    padding = search_max_char_length(categorize_input_list)
    print_file_list(file_list, padding)
  end
end

def print_directories(directory_file_list, categorize_input_list)
  if categorize_input_list[:option].include?('-l')
    directory_file_list.each_with_index do |list, i|
      block_size = calculate_block_size(list[:file_list], list[:path])
      list[:file_list] = convert_list_segment(list[:file_list], list[:path])
      padding_list = (0..6).map { |n| Matrix.columns(list[:file_list]).row(n).max.to_s.length }
      print_hash_segment(list, block_size, padding_list)
      puts if i < directory_file_list.length - 1
    end
  else
    directory_file_list = directory_file_list.each { |list| list[:file_list] = convert_array_for_print list[:file_list] }
    print_hash_list(directory_file_list, search_max_char_length(categorize_input_list))
  end
end

def print_hash_segment(hash_list, block_size, padding_list)
  puts "#{hash_list[:path]}:" if hash_list.size > 1
  puts "total #{block_size}"
  print_list_segment(hash_list[:file_list], padding_list)
end

def print_list_segment(lists, padding_list)
  lists.each do |list|
    list.each_with_index do |file, i|
      if i < 5
        print "#{file.to_s.rjust(padding_list[i])} "
        # 所有者とグループのところだけ空白2つっぽいので帳尻を合わせる
        print ' ' if i > 1 && i < 4
      else
        print "#{file} "
      end
    end
    puts
  end
end

def construct_list_segment(file_name, path)
  list = []
  full_file_name = "#{path}/#{file_name}"
  file_info = File.lstat(full_file_name) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
  list.push("#{replace_file_type(full_file_name)}#{parsing_permission(file_info.mode)}")
  list.push(file_info.nlink.to_s.rjust(2), Etc.getpwuid(file_info.uid).name, Etc.getgrgid(file_info.gid).name, file_info.size)
  month = file_info.mtime.to_a[4].to_s.rjust(2)
  day = file_info.mtime.to_a[3].to_s.rjust(2)
  clock = file_info.mtime.to_a[2].to_s.rjust(2, '0')
  minitus = file_info.mtime.to_a[1].to_s.rjust(2, '0')
  list.push("#{month} #{day} #{clock}:#{minitus}")
  file_name = "#{file_name} -> #{File.readlink(full_file_name)}" if file_info.symlink?
  list.push(file_name)
end

def replace_file_type(file_name)
  { file: '-', directory: 'd', link: 'l' }[File.ftype(file_name)]
end

def parsing_permission(file_mode)
  owener_permission = ((file_mode >> 6) % 8)
  group_permission = ((file_mode >> 3) % 8)
  other_permission = file_mode % 8
  "#{PERMISSION_ARRAY[owener_permission]}#{PERMISSION_ARRAY[group_permission]}#{PERMISSION_ARRAY[other_permission]}"
end

main
