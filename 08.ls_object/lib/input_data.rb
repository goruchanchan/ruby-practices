#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class InputData
  attr_reader :error_list, :option_hash_list, :file_list, :directory_list

  def initialize
    @error_list = []
    @option_hash_list = {}
    @file_list = []
    @directory_list = []
  end

  def argument_parsing
    opt = OptionParser.new
    opt.on('-a') { |v| @option_hash_list[:a] = v }
    opt.on('-r') { |v| @option_hash_list[:r] = v }
    opt.on('-l') { |v| @option_hash_list[:l] = v }
    opt.parse!(ARGV)
    ARGV
  end

  def argv_parsing
    argument_parsing.each do |path|
      if FileTest.directory?(path)
        @directory_list.push(path)
      elsif FileTest.file?(path)
        @file_list.push(path)
      else
        @error_list.push(path)
      end
    end

    @directory_list.push('.') if @file_list.empty? && @directory_list.empty? && @error_list.empty?
  end

  def max_char_length
    all_file_name = @file_list + retrieve_file_list(@directory_list)
    all_file_name.empty? ? 0 : all_file_name.max_by(&:length).length + 1
  end

  def retrieve_file_list(search_paths)
    if @option_hash_list[:a]
      # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
      search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
    else
      search_paths.flat_map { |path| Dir.glob('*', base: path) }
    end
  end
end
