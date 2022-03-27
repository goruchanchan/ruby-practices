#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_COLUMN = 3

def retrieve_file_list(search_paths)
  target_paths_file_list = []
  search_paths.each do |path|
    file_list = Dir.glob("*", base: path).sort_by{|x| x.to_i }
    target_paths_file_list << {path: path, file_list: file_list}
  end
  target_paths_file_list
end

def convert_array(lists)
  transpose_paths = []
  padding_num = lists.max {|a, b| a.length <=> b.length }.length

  if lists.length % MAX_COLUMN != 0
    start_fill_nil = lists.length + 1
    end_fill_nil = ((lists.length / MAX_COLUMN) + 1) * MAX_COLUMN - 1
    column = (lists.length / MAX_COLUMN) + 1
    lists.fill(nil,start_fill_nil..end_fill_nil).each_slice(column){|split_array| transpose_paths.push(split_array)}
  else
    column = (lists.length / MAX_COLUMN)
    lists.each_slice(column){|split_array| transpose_paths.push(split_array)}
  end

  transpose_paths.transpose
end

def view_hash_list(hash_list, padding_num)
  hash_list.each_with_index do |file_list,i|
    puts file_list[:path] + ":" if hash_list.size > 1
    view_file_list(file_list[:file_list], 10)
    puts if i < hash_list.length - 1
  end
end

def view_file_list(file_list, padding_num)
  file_list.each do |file_column|
    file_column.each do |file_name|
      print file_name.to_s.ljust(padding_num + 2)
    end
    puts
  end
end

paths = ARGV

file_paths = []
dir_paths = []
error_paths = []

paths.each do |path|
  if FileTest.directory?(path)
    dir_paths.push(path)
  elsif FileTest.file?(path)
    file_paths.push(path)
  else
    error_paths.push(path)
  end
end

if error_paths.size > 0
  error_paths.sort_by{|x| x.to_i }.each  { |error_path| puts "ls: " + error_path + ": No such file or directory" }
end

file_list = []
if file_paths.size > 0
  file_list = convert_array(file_paths.sort_by{|x| x.to_i }) if file_paths.size > 0
  view_file_list(file_list,10)
end

if(file_paths.size == 0 && dir_paths.size == 0 && error_paths.size == 0)
  dir_paths.push('.')
end
dir_list = []
if dir_paths.size > 0
  dir_list = retrieve_file_list(dir_paths.sort_by{|x| x.to_i }) if dir_paths.size > 0
  dir_list.each do |list|
    list[:file_list] = convert_array list[:file_list]
  end
  puts if error_paths.size > 0 || file_paths.size > 0
  view_hash_list(dir_list,10)
end
