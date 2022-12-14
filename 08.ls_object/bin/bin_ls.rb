#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input'
require_relative '../lib/formatter'

require 'optparse'

options = {}
opt = OptionParser.new
opt.on('-a') { |v| options[:all] = v }
opt.on('-r') { |v| options[:reverse] = v }
opt.on('-l') { |v| options[:long] = v }
opt.parse!(ARGV)

input = Input.new(paths: ARGV, option_all: options[:all], option_reverse: options[:reverse])
puts Formatter.new(groups: input.groups, option_long: options[:long]).to_s
