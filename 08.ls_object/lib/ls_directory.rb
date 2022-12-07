#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'
require_relative 'ls_file'

class LsDirectory < LsFile
  def initialize(input_data)
    super
    @directories = []
  end

  def ls
    @directories = if @input_data.option_reverse
                     reverse_hashes(retrieve_hashes)
                   else
                     retrieve_hashes
                   end

    @input_data.option_long ? direcoty_long_message : direcoty_message
  end

  def direcoty_message
    @directories = @directories.each { |list| list[:file_list] = Formatter.convert_array list[:file_list] }
    @directories.map do |file_list|
      "#{arrange_directory_name(file_list[:path])}#{file_message(file_list[:file_list])}".concat("\n")
    end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
  end

  def direcoty_long_message
    @directories.map do |list|
      block_size = calculate_block_size(list[:file_list], list[:path])
      list[:file_list] = Formatter.convert_list_segment(list[:file_list], list[:path])
      padding_list = (0..6).map { |n| Matrix.columns(list[:file_list]).row(n).max.to_s.length }
      "#{arrange_directory_name(list[:path])}total #{block_size}\n#{file_long_message(list[:file_list], padding_list)}\n"
    end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
  end

  def calculate_block_size(file_list, path)
    file_list.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
  end

  def arrange_directory_name(dir_name)
    "#{dir_name}:\n" if @input_data.names.size > 1
  end

  def retrieve_hashes
    if @input_data.option_all
      # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
      @input_data.names.map { |path| { path: path, file_list: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort_by(&:to_s) } }
    else
      @input_data.names.map { |path| { path: path, file_list: Dir.glob('*', base: path) } }
    end
  end

  def reverse_hashes(hashes)
    # ".."がsortメソッドでうまくソートされなかったので、sort_byでString型にしてソートする
    hashes.reverse.map { |key| { path: key[:path], file_list: key[:file_list].sort_by(&:to_s).reverse } }
  end
end
