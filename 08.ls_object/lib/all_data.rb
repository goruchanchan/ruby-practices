#!/usr/bin/env ruby
# frozen_string_literal: true

class AllData
  attr_reader :error_list, :option_list, :file_list, :directory_list

  def initialize
    @error_list = []
    @option_list = []
    @file_list = []
    @directory_list = []
  end

  def argument_parsing
    raw_argument = []
    ARGV.each do |argument|
      break unless argument.include?('-')

      raw_argument.push(argument)
    end

    options = []
    raw_argument.each do |option|
      options.push('-a') if option.include?('a')
      options.push('-r') if option.include?('r')
      options.push('-l') if option.include?('l')
    end

    { argument: raw_argument, argument_option: options }
  end

  def argv_parsing
    argument = argument_parsing
    (ARGV - argument[:argument]).each do |path|
      if FileTest.directory?(path)
        @directory_list.push(path)
      elsif FileTest.file?(path)
        @file_list.push(path)
      else
        @error_list.push(path)
      end
    end

    @option_list = argument[:argument_option].sort
    @directory_list.push('.') if @file_list.empty? && @directory_list.empty? && @error_list.empty?
  end

  def max_char_length
    (@file_list + retrieve_file_list(@directory_list)).empty? ? 0 : (@file_list + retrieve_file_list(@directory_list)).max_by(&:length).length + 1
  end

  def retrieve_file_list(search_paths)
    if @option_list.include?('-a')
      # "".."を入れる方法がわからなかったので、ここで入れる。文字最大長を知りたいだけなのでソート不要
      search_paths.flat_map { |path| Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') }
    else
      search_paths.flat_map { |path| Dir.glob('*', base: path) }
    end
  end
end
