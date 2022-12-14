#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'matrix'

class Formatter
  PERMISSION_ARRAY = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze
  MAX_COLUMN = 3

  def initialize(groups:, option_long:)
    @groups = groups
    @max_char_length = search_max_char_length
    @option_long = option_long
    @not_nil_group_num = total_not_nil_group
  end

  def search_max_char_length
    all_names = @groups.flat_map(&:files)
    all_names.empty? ? 0 : all_names.max_by(&:length).length + 1
  end

  def total_not_nil_group
    count = 0
    @groups.map { |group| count += 1 unless group.title.nil? }
    count
  end

  def to_s
    @option_long ? long_format : normal_format
  end

  def long_format
    @groups.map do |group|
      if group.title.nil?
        long_message(convert_list_segment(group.files, '.'))
      else
        long_files = convert_list_segment(group.files, group.title)
        "#{group.title}:\ntotal #{total_block_size(group.files, group.title)}\n#{long_message(long_files)}"
      end
    end.join("\n\n")
  end

  def convert_list_segment(names, path)
    names.map { |name| construct_long_segment(name, path) }
  end

  def total_block_size(files, path)
    files.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
  end

  def construct_long_segment(name, path)
    full_name = "#{path}/#{name}"
    long_info = File.lstat(full_name) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
    month = long_info.mtime.to_a[4].to_s.rjust(2)
    day = long_info.mtime.to_a[3].to_s.rjust(2)
    clock = long_info.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = long_info.mtime.to_a[1].to_s.rjust(2, '0')
    name = "#{name} -> #{File.readlink(full_name)}" if long_info.symlink?
    ["#{file_type(full_name)}#{file_permit(long_info.mode)}",
     long_info.nlink, Etc.getpwuid(long_info.uid).name, Etc.getgrgid(long_info.gid).name, long_info.size,
     "#{month} #{day} #{clock}:#{minitus}", name]
  end

  def file_type(name)
    { file: '-', directory: 'd', link: 'l' }[File.ftype(name).intern]
  end

  def file_permit(mode)
    owener_permission = ((mode >> 6) % 8)
    group_permission = ((mode >> 3) % 8)
    other_permission = mode % 8
    "#{PERMISSION_ARRAY[owener_permission]}#{PERMISSION_ARRAY[group_permission]}#{PERMISSION_ARRAY[other_permission]}"
  end

  def long_message(long_files)
    paddings = (0..6).map { |n| Matrix.columns(long_files).row(n).max.to_s.length }

    long_files.map do |file|
      file.map.each_with_index do |long_segment, i|
        if i == file.size - 1
          long_segment.dup
        else
          # 所有者とグループのところだけ空白2つっぽいので帳尻を合わせる
          %w[0 2 3].include?(i.to_s) ? long_segment.to_s.ljust(paddings[i]).to_s.concat('  ') : long_segment.to_s.rjust(paddings[i]).to_s.concat(' ')
        end
      end.join
    end.join("\n")
  end

  def normal_format
    @groups.map do |group|
      result = (group.title.nil? || @not_nil_group_num < 2) ? '' : "#{group.title}:\n"
      result + normal_message(convert_array(group.files))
    end.join("\n\n")
  end

  def convert_array(list)
    if list.length % MAX_COLUMN != 0
      # 行列変換させるために足りない要素にnilをつめていく
      start_fill_nil = list.length + 1
      end_fill_nil = (((list.length / MAX_COLUMN) + 1) * MAX_COLUMN - 1)
      column = (list.length / MAX_COLUMN) + 1
      list.fill(nil, start_fill_nil..end_fill_nil)
    else
      # 転置してMAX_COLUMN列にするので、sliceではMAX_COLUMN行にする
      column = (list.length / MAX_COLUMN)
    end
    list.each_slice(column).map { |split_array| split_array }.transpose
  end

  def normal_message(files)
    files.map do |file|
      file.map.with_index { |name, i| file[i + 1].nil? ? name.to_s : name.to_s.ljust(@max_char_length + 1) }.join
    end.join("\n")
  end
end
