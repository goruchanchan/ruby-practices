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
    classfy_type
  end

  private

  def classfy_type
    files = []
    directories_path = []
    @paths.each { |path| FileTest.directory?(path) ? directories_path.push(path) : files.push(path) }

    @groups.push(FileGroup.new(nil, files)) unless files.empty?
    directories_path.each { |path| @groups.push(FileGroup.new(path, parse_option(path: path))) }
  end

  def parse_option(path:)
    names = @option_all ? Dir.glob('*', File::FNM_DOTMATCH, base: path).push('..') : Dir.glob('*', base: path)
    @option_reverse ? names.sort_by(&:to_s).reverse : names.sort_by(&:to_s)
  end
end
