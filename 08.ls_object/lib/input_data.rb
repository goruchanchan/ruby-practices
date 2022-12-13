#!/usr/bin/env ruby
# frozen_string_literal: true

# class InputData
#   # 入力値からファイル整理して出せる情報を整理するクラスにする。
#   attr_reader :names
#   attr_accessor :max_char_length

#   def initialize(names, options)
#     @names = names
#     @option_all = options[:a]
#     @option_long = options[:l]
#     @option_reverse = options[:r]
#     @all_names = retrieve_files
#     @max_char_length = search_max_char_length
#   end

#   def search_max_char_length
#     @all_names.empty? ? 0 : @all_names.max_by(&:length).length + 1
#   end

#   def retrieve_files
#     if @option_all
#       # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
#       @names.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
#     else
#       @names.flat_map { |path| Dir.glob('*', base: path) }
#     end
#   end
# end

# 入力を整理するクラス
class Input
  attr_reader :group

  def initialize(paths:, option_all:, option_long:, option_reverse:)
    @option_all = option_all
    @option_reverse = option_reverse

    @paths = paths.empty? ? ['.'] : paths
    @paths = @option_reverse ? @paths.reverse : @paths

    @files = []
    @directories = []
    classfy_type

    @group = FileGroup.new(files: @files, directories: @directories, option_long: option_long, max_char_length: search_max_char_length)
  end

  def classfy_type
    @paths.map do |path|
      if FileTest.directory?(path)
        @directories.push(Directory.new(path: path, option_all: @option_all, option_reverse: @option_reverse))
      else
        @files.push(File.new(path: path))
      end
    end
  end

  def search_max_char_length
    all_names = collect_names
    all_names.empty? ? 0 : all_names.max_by(&:length).length + 1
  end

  def collect_names
    @files.flat_map(&:name) + @directories.flat_map(&:names)
  end
end
