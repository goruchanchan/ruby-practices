#!/usr/bin/env ruby
# frozen_string_literal: true

class Game
  def initialize(frames)
    @frames = frames
  end

  def sum_down_marks
    @frames.sum(&:score)
  end

  def sum_additional_marks
    @frames.each_with_index.sum do |frame, i|
      next 0 if i > @frames.length - 2 # 10フレームでは追加点計算をしない
      case frame.score_type
      when :strike
        if @frames[i + 1].score_type == :strike && i < @frames.length - 2# 9フレームにストライクで、10フレームでストライクを取っても次のフレームには移動しないので条件付け
          @frames[i + 1].score_2shots + @frames[i + 2].score_1shot
        else
          @frames[i + 1].score_2shots
        end
      when :spare
        @frames[i + 1].score_1shot
      else
        0
      end
    end
  end

  def score
    sum_down_marks + sum_additional_marks
  end
end
