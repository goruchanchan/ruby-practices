#!/usr/bin/env ruby
# frozen_string_literal: true

class FileGroup
  attr_reader :files, :title

  def initialize(title:, files:)
    @title = title
    @files = files
  end
end
