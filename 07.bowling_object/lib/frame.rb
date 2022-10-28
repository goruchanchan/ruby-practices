#!/usr/bin/env ruby
# frozen_string_literal: true

class Frame
  def initialize(frame_shots)
    @first_shot  = frame_shots[0]
    @second_shot = frame_shots[1] unless frame_shots[1].nil?
    @third_shot  = frame_shots[2] unless frame_shots[2].nil?
  end

  def score_1shot
    @first_shot.score
  end

  def score_2shots
    @second_shot.nil? ? score_1shot : score_1shot + @second_shot.score
  end

  def score_frame
    @third_shot.nil? ? score_2shots : score_2shots + @third_shot.score
  end

  def score_type
    return :strike if score_1shot  == 10
    return :spare  if score_2shots == 10
  end
end
