#!/usr/bin/env ruby
# frozen_string_literal: true

module Viewer
  def view_message(names)
    names.map do |column|
      column.map.with_index do |name, i|
        column[i + 1].nil? ? name.to_s : name.to_s.ljust(@input_data.max_char_length + 1)
      end.join
    end.join("\n")
  end

  def view_long_message(long_names)
    paddings = (0..6).map { |n| Matrix.columns(long_names).row(n).max.to_s.length }

    long_names.map do |long_format|
      long_format.map.each_with_index do |element, i|
        if i == long_format.size - 1
          element.dup
        else
          # 所有者とグループのところだけ空白2つっぽいので帳尻を合わせる
          %w[0 2 3].include?(i.to_s) ? element.to_s.ljust(paddings[i]).to_s.concat('  ') : element.to_s.rjust(paddings[i]).to_s.concat(' ')
        end
      end.join
    end.join("\n")
  end
end
