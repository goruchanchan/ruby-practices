#!/usr/bin/env ruby
# frozen_string_literal: true
MAX_COLUMN = 3

def main
  file_paths = []
  directory_paths = []
  error_paths = []
  
   ARGV.each do |path|
    if FileTest.directory?(path)
      directory_paths.push(path)
    elsif FileTest.file?(path)
      file_paths.push(path)
    else
      error_paths.push(path)
    end
  end
  
  directory_paths.push('.') if(file_paths.size == 0 && directory_paths.size == 0 && error_paths.size == 0)
  
  if(file_paths.length > 0 || directory_paths.length > 0)
    all_file_list = file_paths + retrieve_file_list(directory_paths)
    padding_num = ( all_file_list.max {|a, b| a.length <=> b.length }.length ) +1
  end
  
  if error_paths.size > 0
    error_paths.sort_by{|x| x.to_i }.each{|error_path| puts "ls: " + error_path + ": No such file or directory" }
  end
  
  if file_paths.size > 0
    file_list = convert_array_for_view(file_paths.sort_by{|x| x.to_i })
    view_file_list(file_list,padding_num)
  end
  
  if directory_paths.size > 0
    puts if error_paths.size > 0 || file_paths.size > 0
    directory_file_list = retrieve_hash_list(directory_paths.sort_by{|x| x.to_i }).each{ |list| list[:file_list] = convert_array_for_view list[:file_list] }
    view_hash_list(directory_file_list,padding_num)
  end
end

def retrieve_hash_list(search_paths)
  target_paths_file_list = []
  search_paths.each do |path|
    file_list = Dir.glob("*", base: path).sort_by{|x| x.to_i }
    target_paths_file_list << {path: path, file_list: file_list}
  end
  target_paths_file_list
end

def retrieve_file_list(search_paths)
  target_file_list = []
  search_paths.each do |path|
    target_file_list.concat(Dir.glob("*", base: path))
  end
  target_file_list
end

def convert_array_for_view(lists)
  transpose_paths = []

  if lists.length % MAX_COLUMN != 0
    #行列変換させるために足りない要素にnilをつめていく
    start_fill_nil = lists.length + 1
    end_fill_nil = (((lists.length / MAX_COLUMN) + 1) * MAX_COLUMN - 1)
    column = (lists.length / MAX_COLUMN) + 1
    lists.fill(nil,(lists.length + 1)..end_fill_nil)
  else
    #転置してMAX_COLUMN列にするので、sliceではMAX_COLUMN行にする
    column = (lists.length / MAX_COLUMN)
  end

  lists.each_slice(column){ |split_array| transpose_paths.push(split_array) }
  transpose_paths.transpose
end

def view_hash_list(hash_list, padding_num)
  hash_list.each_with_index do |file_list,i|
    puts file_list[:path] + ":" if hash_list.size > 1
    view_file_list(file_list[:file_list], padding_num)
    puts if i < hash_list.length - 1
  end
end

def view_file_list(file_list, padding_num)
  file_list.each do |file_column|
    file_column.each do |file_name|
      print file_name.to_s.ljust(padding_num)
    end
    puts
  end
end

main
