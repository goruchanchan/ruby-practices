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

    @groups = []
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
    @file_paths.nil? ? [] : @file_paths.map { |path| FileDetail.new(path: path) }
  end

  def make_directories_detail
    return [] if @directory_paths.nil?

    @directory_paths.map do |directory_path|
      paths = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: directory_path).push('..') : Dir.glob('*', base: directory_path)
      paths = @option_reverse ? paths.sort_by(&:to_s).reverse : paths.sort_by(&:to_s)
      files = paths.map { |path| FileDetail.new(path: path) }
      { path: directory_path, files: files }
    end
  end

  def create_groups
    @groups.push(FileGroup.new(nil, @files)) unless @files.empty?
    @directories.map { |directory| @groups.push(FileGroup.new(directory[:path], directory[:files])) }
  end
end
