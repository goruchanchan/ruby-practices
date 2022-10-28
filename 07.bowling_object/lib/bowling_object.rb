#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'game'

def calculate_score(input)
  Game.new(input.map { |shot| Shot.new(shot) }).game_score
end

def main
  scores = ARGV[0].split(',')
  puts calculate_score(scores)
end

main
