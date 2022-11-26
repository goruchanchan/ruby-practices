#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'print'

require 'optparse'
require 'etc'
require 'matrix'

# 配列の順番と権限を組み合わせてみました
PERMISSION_ARRAY = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

MAX_COLUMN = 3

def argument_parsing
  raw_argument = []
  ARGV.each do |argument|
    break unless argument.include?('-')

    raw_argument.push(argument)
  end

  options = []
  raw_argument.each do |option|
    options.push('-a') if option.include?('a')
    options.push('-r') if option.include?('r')
    options.push('-l') if option.include?('l')
  end

  { argument: raw_argument, argument_option: options }
end

def argv_parsing
  file_paths = []
  directory_paths = []
  error_paths = []

  argument = argument_parsing

  (ARGV - argument[:argument]).each do |path|
    if FileTest.directory?(path)
      directory_paths.push(path)
    elsif FileTest.file?(path)
      file_paths.push(path)
    else
      error_paths.push(path)
    end
  end

  directory_paths.push('.') if file_paths.empty? && directory_paths.empty? && error_paths.empty?

  { file: file_paths.sort, directory: directory_paths.sort, error: error_paths.sort, option: argument[:argument_option].sort }
end

def print_files(file_list, option_list, padding)
  if option_list.include?('-l')
    file_list = convert_list_segment(file_list, '.')
    padding_list = (0..6).map { |n| Matrix.columns(file_list).row(n).max.to_s.length }
    print_list_segment(file_list, padding_list)
  else
    file_list = convert_array_for_print(file_list)
    print_file_list(file_list, padding)
  end
end

def print_directories(directory_file_list, option_list, padding)
  if option_list.include?('-l')
    directory_file_list.each_with_index do |list, i|
      block_size = calculate_block_size(list[:file_list], list[:path])
      list[:file_list] = convert_list_segment(list[:file_list], list[:path])
      padding_list = (0..6).map { |n| Matrix.columns(list[:file_list]).row(n).max.to_s.length }
      puts "#{list[:path]}:" if directory_file_list.size > 1
      print_hash_segment(list, block_size, padding_list)
      puts if i < directory_file_list.length - 1
    end
  else
    directory_file_list = directory_file_list.each { |list| list[:file_list] = convert_array_for_print list[:file_list] }
    print_hash_list(directory_file_list, padding)
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

def error_message(error_list)
  error_list.map { |error_path| "ls: #{error_path}: No such file or directory" }.join("\n") unless error_list.empty?
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
    file_column.each { |file_name| print file_name.to_s.ljust(padding_num + 1) }
    puts
  end
end

def convert_list_segment(file_list, path)
  file_list.map { |file| construct_list_segment(file, path) }
end

def calculate_block_size(file_list, path)
  file_list.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
end

def print_hash_segment(hash_list, block_size, padding_list)
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
  { file: '-', directory: 'd', link: 'l' }[File.ftype(file_name).intern]
end

def parsing_permission(file_mode)
  owener_permission = ((file_mode >> 6) % 8)
  group_permission = ((file_mode >> 3) % 8)
  other_permission = file_mode % 8
  "#{PERMISSION_ARRAY[owener_permission]}#{PERMISSION_ARRAY[group_permission]}#{PERMISSION_ARRAY[other_permission]}"
end
