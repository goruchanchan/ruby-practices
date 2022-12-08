#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'formatter'
require_relative 'viewer'

class LsFile
  include Formatter
  include Viewer

  def initialize(input_data)
    @input_data = input_data
    @names = []
  end

  def ls
    @names = @input_data.option_reverse ? @input_data.names.reverse : @input_data.names
    @input_data.option_long ? file_long_message : file_message
  end

  def file_message
    view_message(convert_array(@names))
  end

  def file_long_message
    view_long_message(convert_list_segment(@names, '.'))
  end
end
