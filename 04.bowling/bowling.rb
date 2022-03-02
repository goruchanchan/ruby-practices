#!/usr/bin/env ruby

score = ARGV[0]
scores = score.split(',')

shots = []
scores.each do |s|
  if s == 'X' # strike
    shots << 10
  else
    shots << s.to_i
  end
end

total_score = 0
frame_num = 0
one_frame_scores = []

shots.each_with_index do |s,i|
  total_score += s
  one_frame_scores << s

  if frame_num < 9
    if one_frame_scores.size == 1
      if one_frame_scores.sum == 10 #strike
        total_score += shots[i+1] + shots[i+2]
        one_frame_scores.clear
        frame_num += 1
      end
    end
    if one_frame_scores.size == 2 
      if one_frame_scores.sum == 10 #spare
        total_score += shots[i+1]
      end
      frame_num += 1
      one_frame_scores.clear
    end
  end
end

puts total_score.to_s
