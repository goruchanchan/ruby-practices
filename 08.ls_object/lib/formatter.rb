# frozen_string_literal: true

require 'etc'
require 'matrix'

class Formatter
  PERMISSIONS = ['---', '--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze
  MAX_COLUMN = 3

  def initialize(groups:, option_long:)
    @groups = groups[:group]
    @max_char_length = groups[:max_char_length]
    @option_long = option_long
  end

  def to_s
    @option_long ? long_format : normal_format
  end

  private

  def long_format
    @groups.map do |group|
      if group.title.nil?
        long_message(files: group.files)
      else
        title = @groups.size > 1 ? "#{group.title}:\n" : ''
        message = long_message(files: group.files)
        "#{title}total #{group.total_block_size}\n#{message}"
      end
    end.join("\n\n")
  end

  def long_message(files:)
    files = to_long_format(files: files)
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

  def to_long_format(files:)
    files.map { |file| [file.attribute, file.nlink, file.uname, file.gname, file.size, file.time, file.name] }
  end

  def normal_format
    @groups.map do |group|
      result = group.title.nil? || @groups.size < 2 ? '' : "#{group.title}:\n"
      result + normal_message(files: group.files, max_char_length: @max_char_length + 1)
    end.join("\n\n")
  end

  def normal_message(files:, max_char_length:)
    to_matrix(files: files).map do |file|
      file.map.with_index do |name, i|
        next if name.nil?

        file[i + 1].nil? ? name.name : name.name.ljust(max_char_length)
      end.join
    end.join("\n")
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
end
