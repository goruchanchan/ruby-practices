# frozen_string_literal: true

class FileGroup
  attr_reader :title, :files, :total_block_size

  def initialize(title:, files:)
    @title = title
    @files = files
    @total_block_size = sum_block_size
  end

  def self.max_char_length(group:)
    max_length = group.files.flat_map(&:name).max_by(&:length).length
    group.title.nil? ? max_length + 1 : max_length + 3 # File と Directory でスペースの開け方が異なる
  end

  private

  def sum_block_size
    @files.map { |file| File.lstat(file.path).blocks }.sum
  end
end
