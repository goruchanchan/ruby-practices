#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'game'

def consist_frames(shots)
  frame_shots = []
  frames = []
  shots.each do |shot|
    frame_shots << shot
    if ((frame_shots.size % 2).zero? || shot.score == 10) && frames.size < 9 # 〜9フレーム目
      frames << Frame.new(frame_shots)
      frame_shots.clear
    end
  end
  frames << Frame.new(frame_shots) # 10フレーム目
  frames
end

def calculate_game(frames)
  Game.new(frames)
end

def main(shots = nil)
  shots = ARGV[0].split(',') if shots.nil?
  frames = consist_frames(shots.map { |shot| Shot.new(shot) })
  game = calculate_game(frames)
  game.score
end

#puts main
