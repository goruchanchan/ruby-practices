#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'
require_relative 'viewer'

# class LsFile
  # include Formatter
  # include Viewer

  # def initialize(path)
  #   @path = path
  # end

  # def ls
  #   @names = @input_data.option_reverse ? @input_data.names.reverse : @input_data.names
  #   @input_data.option_long ? file_long_message : file_message
  # end

  # def file_message
  #   view_message(convert_array(@names))
  # end

  # def file_long_message
  #   view_long_message(convert_list_segment(@names, '.'))
  # end
# end

# ファイル情報を集めただけのクラス
class File
  attr_reader :name

  def initialize(path:)
    @name = path
  end
end

# ディレクトリ情報を集めただけのクラス
class Directory
  attr_reader :title, :names

  def initialize(path:, option_all:, option_reverse:)
    @title = path
    @names = option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') : Dir.glob('*', base: path)
    @names = option_reverse ? @names.sort_by(&:to_s).reverse : @names.sort_by(&:to_s)
  end
end

# ファイルまたはディレクトリ毎にまとめるだけのクラス
class FileGroup
  attr_reader :group, :option_long, :max_char_length

  def initialize(files:, directories:, option_long:, max_char_length:)
    @group = []
    @group.push(files).push(directories)
    @option_long = option_long
    @max_char_length = max_char_length
  end
end
