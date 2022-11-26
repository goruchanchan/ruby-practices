#!/usr/bin/env ruby
# frozen_string_literal: true

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
    file_column.each { |file_name| print file_name.to_s.ljust(padding_num + 1) }
    puts
  end
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
      puts "#{list[:path]}:" if directory_file_list.size > 1
      print_hash_segment(list, block_size, padding_list)
      puts if i < directory_file_list.length - 1
    end
  else
    directory_file_list = directory_file_list.each { |list| list[:file_list] = convert_array_for_print list[:file_list] }
    print_hash_list(directory_file_list, search_max_char_length(categorize_input_list))
  end
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
