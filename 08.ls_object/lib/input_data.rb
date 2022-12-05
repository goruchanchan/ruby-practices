#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class InputData
  attr_reader :errors, :options, :files, :directories

  def initialize
    @errors = []
    @options = {}
    @files = []
    @directories = []
  end

  def argument_parsing
    opt = OptionParser.new
    opt.on('-a') { |v| @options[:a] = v }
    opt.on('-r') { |v| @options[:r] = v }
    opt.on('-l') { |v| @options[:l] = v }
    opt.parse!(ARGV)
    ARGV
  end

  def argv_parsing
    argument_parsing.each do |path|
      if FileTest.directory?(path)
        @directories.push(path)
      elsif FileTest.file?(path)
        @files.push(path)
      else
        @errors.push(path)
      end
    end

    @directories.push('.') if @files.empty? && @directories.empty? && @errors.empty?
  end

  def max_char_length
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
