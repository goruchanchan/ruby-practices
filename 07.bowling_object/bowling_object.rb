#!/usr/bin/env ruby
# frozen_string_literal: true

class Shot
  def initialize(mark)
    @mark = mark
  end
  def score
    return 10 if @mark == 'X'
    @mark.to_i
  end
end

score = ARGV[0]
scores = score.split(',')

shots = scores.map { |s| Shot.new(s) }

total_score = 0
frame_num = 1
one_frame_scores = []

shots.each_with_index do |s, i|
total_score += s.score
one_frame_scores << s.score

  if frame_num < 10 && one_frame_scores.sum == 10
    total_score += if one_frame_scores.length == 1
                     shots[i + 1].score + shots[i + 2].score # strike
                   else
                     shots[i + 1].score # spare
                   end
  end

  if one_frame_scores.length == 2 || one_frame_scores.sum == 10
    frame_num += 1
    one_frame_scores.clear
  end
end

puts total_score
