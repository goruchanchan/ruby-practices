#!/usr/bin/env ruby
# frozen_string_literal: true

FileGroup = Struct.new(:title, :files)

class Input
  attr_reader :groups

  def initialize(paths:, option_all:, option_reverse:)
    @option_all = option_all
    @option_reverse = option_reverse

    @paths = paths.empty? ? ['.'] : paths
    @paths = @option_reverse ? @paths.reverse : @paths

    @groups = []
    create_groups
  end

  private

  def separate_by_type
    files = []
    directory_paths = []
    @paths.each { |path| FileTest.directory?(path) ? directory_paths.push(path) : files.push(path) }
    { files: files, directory_paths: directory_paths }
  end

  def create_groups
    separated_group = separate_by_type
    @groups.push(FileGroup.new(nil, separated_group[:files])) unless separated_group[:files].empty?
    separated_group[:directory_paths].each do |directory_path|
      names = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: directory_path).push('..') : Dir.glob('*', base: directory_path)
      names = @option_reverse ? names.sort_by(&:to_s).reverse : names.sort_by(&:to_s)
      @groups.push(FileGroup.new(directory_path, names))
    end
  end
end
