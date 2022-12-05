#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'

class LsFile
  def self.ls(files, options, padding)
    files = files.reverse if options[:r]

    if options[:l]
      long_files = Formatter.convert_list_segment(files, '.')
      padding_list = (0..6).map { |n| Matrix.columns(long_files).row(n).max.to_s.length }
      file_long_message(long_files, padding_list)
    else
      files = Formatter.convert_array(files)
      file_message(files, padding)
    end
  end

  def self.file_error(errors)
    errors.map { |error_path| "ls: #{error_path}: No such file or directory" }.join("\n") unless errors.empty?
  end

  def self.file_message(files, padding_num)
    files.map do |column|
      column.map.with_index do |file_name, i|
        column[i + 1].nil? ? file_name.to_s : file_name.to_s.ljust(padding_num + 1)
      end.join
    end.join("\n")
  end

  def self.file_long_message(files, padding_list)
    files.map do |file_long_format|
      file_long_format.map.each_with_index do |element, i|
        if i == file_long_format.size - 1
          element.dup
        else
          # 所有者とグループのところだけ空白2つっぽいので帳尻を合わせる
          %w[0 2 3].include?(i.to_s) ? element.to_s.ljust(padding_list[i]).to_s.concat('  ') : element.to_s.rjust(padding_list[i]).to_s.concat(' ')
        end
      end.join
    end.join("\n")
  end
end
