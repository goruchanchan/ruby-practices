# frozen_string_literal: true

require_relative 'file_detail'
require_relative 'file_group'

class Input
  attr_reader :groups

  def initialize(paths:, option_all:, option_reverse:)
    @option_all = option_all
    @option_reverse = option_reverse

    @input_paths = paths
    @organized_paths = organize_paths

    @paths = paths_separate_by_type
    @files = make_files_detail
    @directories = make_directories_detail

    @groups = { group: [], max_char_length: 0 }
    @groups[:group] = create_groups
    @groups[:max_char_length] = search_max_char_length
  end

  private

  def organize_paths
    @input_paths = ['.'] if @input_paths.empty?
    @option_reverse ? @input_paths.reverse : @input_paths
  end

  def paths_separate_by_type
    paths_file = []
    paths_directory = []
    @organized_paths.each { |path| FileTest.directory?(path) ? paths_directory.push(path) : paths_file.push(path) }
    { file: paths_file, directory: paths_directory }
  end

  def make_files_detail
    @paths[:file].nil? ? [] : @paths[:file].map { |path| FileDetail.new(path: nil, name: path) }
  end

  def make_directories_detail
    return [] if @paths[:directory].nil?

    @paths[:directory].map do |directory_path|
      names = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: directory_path).push('..') : Dir.glob('*', base: directory_path)
      names = @option_reverse ? names.sort_by(&:to_s).reverse : names.sort_by(&:to_s)
      files = names.map { |name| FileDetail.new(path: directory_path, name: name) }
      { path: directory_path, files: files }
    end
  end

  def create_groups
    if @files.empty?
      @directories.map { |directory| FileGroup.new(title: directory[:path], files: directory[:files]) }
    else
      [FileGroup.new(title: nil, files: @files)].concat(@directories.map { |directory| FileGroup.new(title: directory[:path], files: directory[:files]) })
    end
  end

  def search_max_char_length
    all_files = @groups[:group].flat_map(&:files).map(&:path)
    all_files.empty? ? 0 : all_files.max_by(&:length).length + 1
  end
end
