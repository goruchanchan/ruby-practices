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

class Frame
  attr_reader :first_shot, :second_shot
  def initialize(first_shot, second_shot = nil, third_shot = nil)
    @first_shot = first_shot
    @second_shot = second_shot
    @third_shot = third_shot
  end

  def score
    frame_score = @first_shot.score
    frame_score += @second_shot.score unless @second_shot.nil?
    frame_score += @third_shot.score unless @third_shot.nil?
    frame_score
  end
end

def calculate_score(input)
  shots = input.map { |s| Shot.new(s) }

  frame_shots = []
  frame_scores = []

  shots.each_with_index do |s, i|
    frame_shots << s
    if frame_scores.size < 9 # 〜9投目
      if frame_shots.size % 2 == 0 || s.score == 10
        frame_scores << if frame_shots.size == 1
                          Frame.new(frame_shots[0])
                        else
                          Frame.new(frame_shots[0], frame_shots[1])
                        end
        frame_shots.clear
      end
    else # 10投目
      if frame_shots.size == 3 || (frame_shots.size == 2 && (frame_shots[0].score + frame_shots[1].score < 10) )
        frame_scores << if frame_shots.size == 3
                          Frame.new(frame_shots[0], frame_shots[1], frame_shots[2])
                        else
                          Frame.new(frame_shots[0], frame_shots[1])
                        end
      end
    end
  end
  total_score = 0

  frame_scores.each_with_index do |s, i|
    total_score += s.score
    if i < 9 && s.score == 10
      total_score += if s.second_shot.nil? #strike
                       if frame_scores[i + 1].second_shot.nil?
                        frame_scores[i + 1].score + frame_scores[i + 2].first_shot.score
                       else
                        # frame_scores[i + 1].score だと10フレーム目で３投目を余分に足してしまうので、下の形式
                        frame_scores[i + 1].first_shot.score + frame_scores[i + 1].second_shot.score
                       end
                     else # spare
                       frame_scores[i + 1].first_shot.score
                     end
    end
  end
  total_score
end

def main
  scores = ARGV[0].split(',')
  puts calculate_score(scores)
end
