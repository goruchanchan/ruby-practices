#!/usr/bin/env ruby
# frozen_string_literal: true

class InputData
  attr_reader :names, :option_all, :option_long, :option_reverse,
              :options
  attr_accessor :max_char_length

  def initialize(names, options)
    @names = names
    @option_all = options[:a]
    @option_long = options[:l]
    @option_reverse = options[:reverse]
    @max_char_length = search_max_char_length
    @options = options # 最終的に消す
  end

  def search_max_char_length
    all_file_name = retrieve_files(@names)
    all_file_name.empty? ? 0 : all_file_name.max_by(&:length).length + 1
  end

  def retrieve_files(search_paths)
    if @option_all
      # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
      search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
    else
      search_paths.flat_map { |path| Dir.glob('*', base: path) }
    end
  end
end
