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
  attr_reader :groups

  def initialize(paths:, option_all:, option_reverse:)
    @option_all = option_all
    @option_reverse = option_reverse

    @paths = paths.empty? ? ['.'] : paths
    @paths = @option_reverse ? @paths.reverse : @paths

    @groups = []
    classfy_type
  end

  private

  def classfy_type
    files = []
    directories_path = []
    @paths.each { |path| FileTest.directory?(path) ? directories_path.push(path) : files.push(path) }

    @groups.push(FileGroup.new(title: nil, files: files)) unless files.empty?
    directories_path.each { |path| @groups.push(FileGroup.new(title: path, files: parse_option(path))) }
  end

  def parse_option(path)
    names = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') : Dir.glob('*', base: path)
    @option_reverse ? names.sort_by(&:to_s).reverse : names.sort_by(&:to_s)
  end
end
