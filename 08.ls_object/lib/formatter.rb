#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'matrix'

class Formatter
  PERMISSIONS = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze
  MAX_COLUMN = 3

  def initialize(groups:, option_long:)
    @groups = groups
    @option_long = option_long
    @not_nil_group_num = total_not_nil_group
  end

  def to_s
    @option_long ? long_format : normal_format
  end

  private

  def search_max_char_length
    all_names = @groups.flat_map(&:files)
    all_names.empty? ? 0 : all_names.max_by(&:length).length + 1
  end

  def total_not_nil_group
    count = 0
    @groups.each { |group| count += 1 unless group.title.nil? }
    count
  end

  def long_format
    @groups.map do |group|
      if group.title.nil?
        long_message(files: to_long_format_files(files: group.files, path: '.'))
      else
        long_files = to_long_format_files(files: group.files, path: group.title)
        title = @not_nil_group_num > 1 ? "#{group.title}:\n" : ''
        "#{title}total #{total_block_size(files: group.files, path: group.title)}\n#{long_message(files: long_files)}"
      end
    end.join("\n\n")
  end

  def to_long_format_files(files:, path:)
    files.map { |file| to_long_format(file: file, path: path) }
  end

  def total_block_size(files:, path:)
    files.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
  end

  def to_long_format(file:, path:)
    full_path = "#{path}/#{file}"
    long_info = File.lstat(full_path) # statだとシンボリックリンクのパスが元ファイルになってしまうので、lstat
    month = long_info.mtime.to_a[4].to_s.rjust(2)
    day = long_info.mtime.to_a[3].to_s.rjust(2)
    clock = long_info.mtime.to_a[2].to_s.rjust(2, '0')
    minitus = long_info.mtime.to_a[1].to_s.rjust(2, '0')
    file = "#{file} -> #{File.readlink(full_path)}" if long_info.symlink?
    ["#{file_type(full_path: full_path)}#{file_permit(mode: long_info.mode)}",
     long_info.nlink, Etc.getpwuid(long_info.uid).name, Etc.getgrgid(long_info.gid).name, long_info.size,
     "#{month} #{day} #{clock}:#{minitus}", file]
  end

  def file_type(full_path:)
    { file: '-', directory: 'd', link: 'l' }[File.ftype(full_path).intern]
  end

  def file_permit(mode:)
    owener = ((mode >> 6) % 8)
    group = ((mode >> 3) % 8)
    other = mode % 8
    "#{PERMISSIONS[owener]}#{PERMISSIONS[group]}#{PERMISSIONS[other]}"
  end

  def long_message(files:)
    paddings = (0..6).map { |n| Matrix.columns(files).row(n).max.to_s.length }

    files.map do |file|
      file.map.each_with_index do |segment, i|
        if i == file.size - 1
          segment.dup
        else
          # 所有者とグループのところだけ空白2つっぽいので帳尻を合わせる
          %w[0 2 3].include?(i.to_s) ? segment.to_s.ljust(paddings[i]).to_s.concat('  ') : segment.to_s.rjust(paddings[i]).to_s.concat(' ')
        end
      end.join
    end.join("\n")
  end

  def normal_format
    @groups.map do |group|
      result = group.title.nil? || @not_nil_group_num < 2 ? '' : "#{group.title}:\n"
      max_char_length = group.title.nil? ? search_max_char_length + 1 : search_max_char_length + 3 # directoryの方が2つ半角が多い
      result + normal_message(files: to_matrix(files: group.files), max_char_length: max_char_length)
    end.join("\n\n")
  end

  def to_matrix(files:)
    if files.length % MAX_COLUMN != 0 # 行列変換させるために足りない要素にnilをつめていく
      start_fill_nil = files.length + 1
      end_fill_nil = (((files.length / MAX_COLUMN) + 1) * MAX_COLUMN - 1)
      column = (files.length / MAX_COLUMN) + 1
      files.fill(nil, start_fill_nil..end_fill_nil)
    else
      column = (files.length / MAX_COLUMN) # 転置してMAX_COLUMN列にするので、sliceではMAX_COLUMN行にする
    end
    files.each_slice(column).map { |split_array| split_array }.transpose
  end

  def normal_message(files:, max_char_length:)
    files.map do |file|
      file.map.with_index { |name, i| file[i + 1].nil? ? name.to_s : name.to_s.ljust(max_char_length) }.join
    end.join("\n")
  end
end
