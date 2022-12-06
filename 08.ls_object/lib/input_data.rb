#!/usr/bin/env ruby
# frozen_string_literal: true

class InputData
  attr_reader :options, :files, :directories, :max_char_length

  def initialize(files, directories, options)
    @files = files
    @directories = directories
    @options = options
    @max_char_length = search_max_char_length
  end

  def search_max_char_length
    all_file_name = @files + retrieve_files(@directories)
    all_file_name.empty? ? 0 : all_file_name.max_by(&:length).length + 1
  end

  def retrieve_files(search_paths)
    if @options[:a]
      # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
      search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
    else
      search_paths.flat_map { |path| Dir.glob('*', base: path) }
    end
  end
end
