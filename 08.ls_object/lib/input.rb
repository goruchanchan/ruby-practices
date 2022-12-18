#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'file_detail'

FileGroup = Struct.new(:title, :files)

class Input
  attr_reader :groups

  def initialize(paths:, option_all:, option_reverse:)
    @option_all = option_all
    @option_reverse = option_reverse

    @paths = paths
    organize_paths

    @file_paths = []
    @directory_paths = []
    separate_by_type
    @files = make_files_detail
    @directories = make_directories_detail

    @groups = { group: [], max_char_length: 0, directories_num: 0 }
    create_groups
  end

  private

  def organize_paths
    @paths = ['.'] if @paths.empty?
    @paths = @option_reverse ? @paths.reverse : @paths
  end

  def separate_by_type
    @paths.each { |path| FileTest.directory?(path) ? @directory_paths.push(path) : @file_paths.push(path) }
  end

  def make_files_detail
    @file_paths.nil? ? [] : @file_paths.map { |path| FileDetail.new(path: nil, name: path) }
  end

  def make_directories_detail
    return [] if @directory_paths.nil?

    @directory_paths.map do |directory_path|
      names = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: directory_path).push('..') : Dir.glob('*', base: directory_path)
      names = @option_reverse ? names.sort_by(&:to_s).reverse : names.sort_by(&:to_s)
      files = names.map { |name| FileDetail.new(path: directory_path, name: name) }
      { path: directory_path, files: files }
    end
  end

  def create_groups
    @groups[:group].push(FileGroup.new(nil, @files)) unless @files.empty?
    @directories.map { |directory| @groups[:group].push(FileGroup.new(directory[:path], directory[:files])) }

    all_files = @groups[:group].flat_map(&:files).map(&:path)
    @groups[:max_char_length] = all_files.empty? ? 0 : all_files.max_by(&:length).length + 1
  end
end
