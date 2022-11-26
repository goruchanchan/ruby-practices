#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'print'

require 'optparse'
require 'etc'
require 'matrix'

# 配列の順番と権限を組み合わせてみました
PERMISSION_ARRAY = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

MAX_COLUMN = 3

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

def convert_list_segment(file_list, path)
  file_list.map { |file| construct_list_segment(file, path) }
end

def calculate_block_size(file_list, path)
  file_list.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
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
