#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'

class LsFile
  def self.ls_files(file_list, option_list, padding)
    file_list = file_list.reverse if option_list.include?('-r')

    if option_list.include?('-l')
      long_file_list = Formatter.convert_list_segment(file_list, '.')
      padding_list = (0..6).map { |n| Matrix.columns(long_file_list).row(n).max.to_s.length }
      file_long_message(long_file_list, padding_list)
    else
      file_list = Formatter.convert_array(file_list)
      file_message(file_list, padding)
    end
  end

  def self.error_message(error_list)
    error_list.map { |error_path| "ls: #{error_path}: No such file or directory" }.join("\n") unless error_list.empty?
  end

  def self.file_message(input_file_list, padding_num)
    input_file_list.map do |column|
      column.map.with_index do |file_name, i|
        column[i + 1].nil? ? file_name.to_s : file_name.to_s.ljust(padding_num + 1)
      end.join
    end.join("\n")
  end

  def self.file_long_message(file_lists, padding_list)
    file_lists.map do |file_long_format|
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
