#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'
require_relative 'viewer'

class LsDirectory
  include Formatter
  include Viewer

  def initialize(input_data)
    @input_data = input_data
    @path_and_names = []
  end

  def ls
    @path_and_names = @input_data.option_reverse ? reverse_retrieve_hashes : retrieve_hashes
    @input_data.option_long ? direcoty_long_message : direcoty_message
  end

  def direcoty_message
    @path_and_names = @path_and_names.each { |list| list[:names] = convert_array list[:names] }
    @input_data.max_char_length += 2 # ディレクトリのネーム間は、ファイルよりも半角2スペース多い
    @path_and_names.map do |list|
      "#{arrange_directory_name(list[:paths])}#{view_message(list[:names])}".concat("\n")
    end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
  end

  def direcoty_long_message
    @path_and_names.map do |list|
      block_size = calculate_block_size(list[:names], list[:paths])
      long_names = convert_list_segment(list[:names], list[:paths])
      "#{arrange_directory_name(list[:paths])}total #{block_size}\n#{view_long_message(long_names)}\n"
    end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
  end

  def calculate_block_size(names, path)
    names.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
  end

  def arrange_directory_name(dir_name)
    "#{dir_name}:\n" if @input_data.names.size > 1
  end

  def retrieve_hashes
    if @input_data.option_all
      # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
      @input_data.names.map { |path| { paths: path, names: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort_by(&:to_s) } }
    else
      @input_data.names.map { |path| { paths: path, names: Dir.glob('*', base: path) } }
    end
  end

  def reverse_retrieve_hashes
    # ".."がsortメソッドでうまくソートされなかったので、sort_byでString型にしてソートする
    retrieve_hashes.reverse.map { |key| { paths: key[:paths], names: key[:names].sort_by(&:to_s).reverse } }
  end
end
