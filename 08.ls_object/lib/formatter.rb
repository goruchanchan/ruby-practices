#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'matrix'

# 配列の順番と権限を組み合わせてみました
PERMISSION_ARRAY = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

MAX_COLUMN = 3

class Formatter
  def self.convert_array(lists)
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

  def self.convert_list_segment(file_list, path)
    file_list.map { |file| construct_list_segment(file, path) }
  end

  def self.construct_list_segment(file_name, path)
    list = []
    full_file_name = "#{path}/#{file_name}"
    file_info = File.lstat(full_file_name) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
    list.push("#{replace_file_type(full_file_name)}#{parsing_permission(file_info.mode)}")
    list.push(file_info.nlink, Etc.getpwuid(file_info.uid).name, Etc.getgrgid(file_info.gid).name, file_info.size)
    month = file_info.mtime.to_a[4].to_s.rjust(2)
    day = file_info.mtime.to_a[3].to_s.rjust(2)
    clock = file_info.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = file_info.mtime.to_a[1].to_s.rjust(2, '0')
    list.push("#{month} #{day} #{clock}:#{minitus}")
    file_name = "#{file_name} -> #{File.readlink(full_file_name)}" if file_info.symlink?
    list.push(file_name)
  end

  def self.replace_file_type(file_name)
    { file: '-', directory: 'd', link: 'l' }[File.ftype(file_name).intern]
  end

  def self.parsing_permission(file_mode)
    owener_permission = ((file_mode >> 6) % 8)
    group_permission = ((file_mode >> 3) % 8)
    other_permission = file_mode % 8
    "#{PERMISSION_ARRAY[owener_permission]}#{PERMISSION_ARRAY[group_permission]}#{PERMISSION_ARRAY[other_permission]}"
  end
end
