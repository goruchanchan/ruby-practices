#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

shots = []
scores.each do |s|
  shots << (s == 'X' ? 10 : s.to_i)
end

total_score = 0
frame_num = 1
one_frame_scores = []

shots.each_with_index do |s, i|
  total_score += s
  one_frame_scores << s

  if frame_num < 10 && one_frame_scores.sum == 10
    total_score += if one_frame_scores.length == 1
                     shots[i + 1] + shots[i + 2] # strike
                   else
                     shots[i + 1] # spare
                   end
  end

  if one_frame_scores.length == 2 || one_frame_scores.sum == 10
    frame_num += 1
    one_frame_scores.clear
  end
end

puts total_score
