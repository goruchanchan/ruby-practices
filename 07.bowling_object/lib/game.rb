#!/usr/bin/env ruby
# frozen_string_literal: true

class Game
  def initialize(shots)
    @total_marks = 0
    @frames = []
    consist_game(shots)
  end

  def consist_game(shots)
    frame_shots = []
    shots.each_with_index do |shot, i|
      frame_shots << shot
      if @frames.size < 9 # 〜9フレーム目
        if (frame_shots.size % 2).zero? || shot.score == 10
          @frames << Frame.new(frame_shots)
          frame_shots.clear
        end
      elsif shots.length - 1 == i # 10フレーム目
        @frames << Frame.new(frame_shots)
      end
    end
  end

  def sum_down_marks
    @frames.each do |frame|
      @total_marks += frame.score_frame
    end
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

  def game_score
    sum_down_marks
    sum_additional_marks
    @total_marks
  end
end
