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
  def initialize(frame_shots)
    @first_shot = frame_shots[0]
    @second_shot = frame_shots[1] unless frame_shots[1].nil?
    @third_shot = frame_shots[2] unless frame_shots[2].nil?
  end

  def score_1shot
    @first_shot.score
  end

  def score_2shots
    @second_shot.nil? ? score_1shot : score_1shot + @second_shot.score
  end

  def score_3shots
    @third_shot.nil? ? score_2shots : score_2shots + @third_shot.score
  end

  def frame_type
    if score_1shot == 10
      return :strike
    elsif (score_2shots == 10)
      return :spare
    end
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
        frame_scores << Frame.new(frame_shots)
        frame_shots.clear
      end
    else # 10投目
      frame_scores << Frame.new(frame_shots) if (shots.length - 1) == i
    end
  end

  total_score = 0
  frame_scores.each_with_index do |s, i|
    total_score += s.score_3shots
    
    if i < 9 
      case s.frame_type
      when :strike
        total_score += if (frame_scores[i + 1].frame_type == :strike && i < 8)
          frame_scores[i + 1].score_2shots + frame_scores[i + 2].score_1shot
        else
          frame_scores[i + 1].score_2shots
        end
      when :spare
        total_score += frame_scores[i + 1].score_1shot
      end
    end
  end
  total_score
end

def main
  scores = ARGV[0].split(',')
  puts calculate_score(scores)
end

#main
