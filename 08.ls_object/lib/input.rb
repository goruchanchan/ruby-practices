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
    directories = []
    @paths.each { |path| FileTest.directory?(path) ? directories.push(path) : files.push(path) }
    { files: files, directories: directories }
  end

  def create_groups
    separated_group = separate_by_type
    @groups.push(FileGroup.new(nil, separated_group[:files])) unless separated_group[:files].empty?
    separated_group[:directories].each { |directory| @groups.push(FileGroup.new(directory, parse_option(path: directory))) }
  end

  def parse_option(path:)
    names = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') : Dir.glob('*', base: path)
    @option_reverse ? names.sort_by(&:to_s).reverse : names.sort_by(&:to_s)
  end
end
