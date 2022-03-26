#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
ENV['POSIXLY_CORRECT'] = '1'
MAX_COLUMN = 3

def retrieve_file_list(paths)
  paths.each_with_index do |path, i|
    puts unless (i == 0)
    puts "#{path}:"
    lists = Dir.glob("*", base: path).sort_by{|x| x.to_i }
    if lists.size > 0
      convert_array lists
    end
  end
end

def convert_array(lists)
  tranpose_paths = []
  padding_num = lists.max {|a, b| a.length <=> b.length }.length

  if lists.length % MAX_COLUMN != 0
    start_fill_nil = lists.length + 1
    end_fill_nil = ((lists.length / MAX_COLUMN) + 1) * MAX_COLUMN - 1
    column = (lists.length / MAX_COLUMN) + 1
    lists.fill(nil,start_fill_nil..end_fill_nil).each_slice(column){|split_array| tranpose_paths.push(split_array)}
  else
    column = (lists.length / MAX_COLUMN)
    lists.each_slice(column){|split_array| tranpose_paths.push(split_array)}
  end

  view_list(tranpose_paths.transpose, padding_num)
end

def view_list(file_list, padding_num)
  file_list.each do |file_row|
    file_row.each do |file_name|
      print file_name.to_s.ljust(padding_num + 2)
    end
    puts
  end
end

opt = OptionParser.new
opt.on('-a')
opt.on('-l')

paths = opt.parse(ARGV)
options = ARGV - paths

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

if(file_paths.size == 0 && dir_paths.size == 0 && error_paths.size == 0)
  no_argument_lists = Dir.glob('*', base: '.').sort_by{|x| x.to_i }
  convert_array no_argument_lists
else
  error_paths.sort_by{|x| x.to_i }.each do |error_path|
    puts "ls: " + error_path + ": No such file or directory"
  end
  retrieve_file_list(file_paths.sort_by{|x| x.to_i })
  retrieve_file_list(dir_paths.sort_by{|x| x.to_i })
end
