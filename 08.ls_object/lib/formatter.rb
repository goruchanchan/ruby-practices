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

  def convert_list_segment(names, path)
    names.map { |name| construct_list_segment(name, path) }
  end

  def construct_list_segment(name, path)
    full_name = "#{path}/#{name}"
    long_info = File.lstat(full_name) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
    month = long_info.mtime.to_a[4].to_s.rjust(2)
    day = long_info.mtime.to_a[3].to_s.rjust(2)
    clock = long_info.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = long_info.mtime.to_a[1].to_s.rjust(2, '0')
    name = "#{name} -> #{File.readlink(full_name)}" if long_info.symlink?
    long_names = []
    long_names.push("#{replace_file_type(full_name)}#{parsing_permission(long_info.mode)}")
    long_names.push(long_info.nlink, Etc.getpwuid(long_info.uid).name, Etc.getgrgid(long_info.gid).name, long_info.size)
    long_names.push("#{month} #{day} #{clock}:#{minitus}")
    long_names.push(name)
  end

  def replace_file_type(name)
    { file: '-', directory: 'd', link: 'l' }[File.ftype(name).intern]
  end

  def parsing_permission(mode)
    owener_permission = ((mode >> 6) % 8)
    group_permission = ((mode >> 3) % 8)
    other_permission = mode % 8
    "#{PERMISSION_ARRAY[owener_permission]}#{PERMISSION_ARRAY[group_permission]}#{PERMISSION_ARRAY[other_permission]}"
  end
end
