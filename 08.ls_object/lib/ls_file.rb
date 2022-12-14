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

# # ファイル情報を集めただけのクラス
# class File
#   attr_reader :name

#   def initialize(path:)
#     @path = path
#   end
# end

# # ディレクトリ情報を集めただけのクラス
# class Directory
#   attr_reader :file_names

#   def initialize(names:)
#     @file_names = names
#   end
# end

# ファイルまたはディレクトリ毎にまとめるだけのクラス
class FileGroup
  attr_reader :files, :title

  def initialize(title:, files:)
    @title = title
    @files = files
  end
end
