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

def ls_files(file_list, option_list, padding)
  file_list = file_list.reverse if option_list.include?('-r')

  if option_list.include?('-l')
    long_file_list = convert_list_segment(file_list, '.')
    padding_list = (0..6).map { |n| Matrix.columns(long_file_list).row(n).max.to_s.length }
    file_long_message(long_file_list, padding_list)
  else
    file_list = convert_array(file_list)
    file_message(file_list, padding)
  end
end

def file_message(input_file_list, padding_num)
  input_file_list.map do |column|
    column.map.with_index do |file_name, i|
      column[i + 1].nil? ? file_name.to_s : file_name.to_s.ljust(padding_num + 1)
    end.join
  end.join("\n")
end

def file_long_message(file_lists, padding_list)
  file_lists.map do |file_long_format|
    file_long_format.map.each_with_index do |element, i|
      if i == file_long_format.size - 1
        element.dup
      else
        # 所有者とグループのところだけ空白2つっぽいので帳尻を合わせる
        %w[2 3].include?(i.to_s) ? element.to_s.ljust(padding_list[i]).to_s.concat('  ') : element.to_s.rjust(padding_list[i]).to_s.concat(' ')
      end
    end.join
  end.join("\n")
end

def retrieve_hash_list(search_paths, options)
  if options.include?('-a')
    # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort_by(&:to_s) } }
  else
    search_paths.map { |path| { path: path, file_list: Dir.glob('*', base: path) } }
  end
end

def parsing_reverse_hash_list(hash_list)
  # ".."がsortメソッドでうまくソートされなかったので、sort_byでString型にしてソートする
  hash_list.reverse.map { |hash| { path: hash[:path], file_list: hash[:file_list].sort_by(&:to_s).reverse } }
end

def ls_directories(directory_list, option_list, padding)
  directory_file_list = retrieve_hash_list(directory_list, option_list)
  directory_file_list = parsing_reverse_hash_list(directory_file_list) if option_list.include?('-r')

  if option_list.include?('-l')
    direcoty_long_message(directory_file_list)
  else
    directory_file_list = directory_file_list.each { |list| list[:file_list] = convert_array list[:file_list] }
    direcoty_message(directory_file_list, padding)
  end
end

def direcoty_message(input_hash_list, padding_num)
  input_hash_list.map do |file_list|
    "#{arrange_directory_name(input_hash_list, file_list[:path])}#{file_message(file_list[:file_list], padding_num + 2)}".concat("\n")
  end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
end

def direcoty_long_message(directory_file_list)
  directory_file_list.map do |list|
    block_size = calculate_block_size(list[:file_list], list[:path])
    list[:file_list] = convert_list_segment(list[:file_list], list[:path])
    padding_list = (0..6).map { |n| Matrix.columns(list[:file_list]).row(n).max.to_s.length }
    "#{arrange_directory_name(directory_file_list, list[:path])}total #{block_size}\n#{file_long_message(list[:file_list], padding_list)}\n"
  end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
end

def calculate_block_size(file_list, path)
  file_list.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
end

def arrange_directory_name(directory_list, directory_path)
  "#{directory_path}:\n" if directory_list.size > 1
end

def convert_array(lists)
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

def convert_list_segment(file_list, path)
  file_list.map { |file| construct_list_segment(file, path) }
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
