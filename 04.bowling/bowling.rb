#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

shots = []
scores.each do |s|
  shots << 10     if     s == 'X'
  shots << s.to_i unless s == 'X'
end

total_score = 0
frame_num = 1
one_frame_scores = []

shots.each_with_index do |s, i|
  total_score += s
  one_frame_scores << s

  if frame_num < 10 && one_frame_scores.sum == 10
    total_score += shots[i + 1] + shots[i + 2] if one_frame_scores.size == 1 # strike
    total_score += shots[i + 1]                if one_frame_scores.size == 2 # spare
  end

  if one_frame_scores.size == 2 || one_frame_scores.sum == 10
    frame_num += 1
    one_frame_scores.clear
  end
end

puts total_score
