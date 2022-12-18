# frozen_string_literal: true

class FileGroup
  attr_reader :title, :files, :total_block_size

  def initialize(title:, files:)
    @title = title
    @files = files
    @total_block_size = sum_block_size
  end

  private

  def sum_block_size
    @files.map { |file| File.lstat(file.path).blocks }.sum
  end
end
