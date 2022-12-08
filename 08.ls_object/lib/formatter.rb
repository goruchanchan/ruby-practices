#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'matrix'

module Formatter
  PERMISSION_ARRAY = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze
  MAX_COLUMN = 3

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
    lists.each_slice(column).map { |split_array| split_array }.transpose
  end

  def convert_list_segment(files, path)
    files.map { |file| construct_list_segment(file, path) }
  end

  def construct_list_segment(file_name, path)
    full_file_name = "#{path}/#{file_name}"
    long_info = File.lstat(full_file_name) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
    month = long_info.mtime.to_a[4].to_s.rjust(2)
    day = long_info.mtime.to_a[3].to_s.rjust(2)
    clock = long_info.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = long_info.mtime.to_a[1].to_s.rjust(2, '0')
    file_name = "#{file_name} -> #{File.readlink(full_file_name)}" if long_info.symlink?
    long_files = []
    long_files.push("#{replace_file_type(full_file_name)}#{parsing_permission(long_info.mode)}")
    long_files.push(long_info.nlink, Etc.getpwuid(long_info.uid).name, Etc.getgrgid(long_info.gid).name, long_info.size)
    long_files.push("#{month} #{day} #{clock}:#{minitus}")
    long_files.push(file_name)
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
end
