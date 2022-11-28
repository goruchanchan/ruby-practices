#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'
require_relative 'ls_file'

class LsDirectory < LsFile
  def self.ls_directories(directory_list, option_list, padding)
    directory_file_list = retrieve_hash_list(directory_list, option_list)
    directory_file_list = parsing_reverse_hash_list(directory_file_list) if option_list.include?('-r')

    if option_list.include?('-l')
      direcoty_long_message(directory_file_list)
    else
      directory_file_list = directory_file_list.each { |list| list[:file_list] = convert_array list[:file_list] }
      direcoty_message(directory_file_list, padding)
    end
  end

  def self.direcoty_message(input_hash_list, padding_num)
    input_hash_list.map do |file_list|
      "#{arrange_directory_name(input_hash_list, file_list[:path])}#{file_message(file_list[:file_list], padding_num + 2)}".concat("\n")
    end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
  end

  def self.direcoty_long_message(directory_file_list)
    directory_file_list.map do |list|
      block_size = calculate_block_size(list[:file_list], list[:path])
      list[:file_list] = convert_list_segment(list[:file_list], list[:path])
      padding_list = (0..6).map { |n| Matrix.columns(list[:file_list]).row(n).max.to_s.length }
      "#{arrange_directory_name(directory_file_list, list[:path])}total #{block_size}\n#{file_long_message(list[:file_list], padding_list)}\n"
    end.join("\n").chomp("\n") # "\n" で結合するが、最後は余分なので削除
  end

  def self.calculate_block_size(file_list, path)
    file_list.map { |file| File.lstat("#{path}/#{file}").blocks }.sum
  end

  def self.arrange_directory_name(directory_list, directory_path)
    "#{directory_path}:\n" if directory_list.size > 1
  end

  def self.retrieve_hash_list(search_paths, options)
    if options.include?('-a')
      # "".."を入れる方法がわからなかったので、ここで入れる。並び替えがずれるので、入れた後にもソートする
      search_paths.map { |path| { path: path, file_list: Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..').sort_by(&:to_s) } }
    else
      search_paths.map { |path| { path: path, file_list: Dir.glob('*', base: path) } }
    end
  end

  def self.parsing_reverse_hash_list(hash_list)
    # ".."がsortメソッドでうまくソートされなかったので、sort_byでString型にしてソートする
    hash_list.reverse.map { |hash| { path: hash[:path], file_list: hash[:file_list].sort_by(&:to_s).reverse } }
  end
end
