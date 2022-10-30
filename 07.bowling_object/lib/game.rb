#!/usr/bin/env ruby
# frozen_string_literal: true

class Game
  def initialize(frames)
    @total_marks = 0
    @frames = frames
  end

  def sum_down_marks
    @total_marks = @frames.sum { |frame| frame.score}
  end

  def sum_additional_marks
    @frames.each_with_index do |frame, i|
      next if i > @frames.length - 2 # 10フレームでは追加点計算をしない

      case frame.score_type
      when :strike
        @total_marks += @frames[i + 1].score_2shots
        # 9フレームにストライクで、10フレームでストライクを取っても次のフレームには移動しないので条件付け
        @total_marks += @frames[i + 2].score_1shot if @frames[i + 1].score_type == :strike && i < @frames.length - 2
      when :spare
        @total_marks += @frames[i + 1].score_1shot
      end
    end
  end

  def score
    sum_down_marks
    sum_additional_marks
    @total_marks
  end
end
