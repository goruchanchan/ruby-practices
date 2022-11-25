#!/usr/bin/env ruby
# frozen_string_literal: true

class Frame
  def initialize(frame_shots)
    @first_shot, @second_shot, @third_shot = frame_shots
  end

  def score_1shot
    @first_shot.score
  end

  def score_2shots
    @second_shot.nil? ? score_1shot : score_1shot + @second_shot.score
  end

  def score
    @third_shot.nil? ? score_2shots : score_2shots + @third_shot.score
  end

  def score_type
    return :strike if score_1shot  == 10
    return :spare  if score_2shots == 10
  end
end
