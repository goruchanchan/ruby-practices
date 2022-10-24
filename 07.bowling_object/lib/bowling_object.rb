#!/usr/bin/env ruby
# frozen_string_literal: true

class Shot
  def initialize(mark)
    @mark = mark
  end
  def score
    @mark == 'X' ? 10 : @mark.to_i
  end
end

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
      if ( @frames.size < 9 && (frame_shots.size % 2 == 0 || shot.score == 10) ) # 〜9フレーム目
        @frames << Frame.new(frame_shots)
        frame_shots.clear
      end
      @frames << Frame.new(frame_shots) if shots.length - 1 == i # 10フレーム目
    end
  end

  def sum_down_marks
    @frames.each do |frame|
      @total_marks += frame.score_frame
    end
  end

  def sum_additional_marks
    @frames.each_with_index do |frame,i|
      if i < 9 
        case frame.score_type
        when :strike
          @total_marks += @frames[i + 1].score_2shots
          # 9フレームにストライクで、10フレームでストライクを取っても次のフレームには移動しない
          @total_marks += @frames[i + 2].score_1shot if @frames[i + 1].score_type == :strike && i < 8
        when :spare
          @total_marks += @frames[i + 1].score_1shot
        end
      end
    end
  end

  def game_score
    sum_down_marks
    sum_additional_marks
    @total_marks
  end
end

def calculate_score(input)
  Game.new( input.map { |shot| Shot.new(shot) } ).game_score
end

def main
  scores = ARGV[0].split(',')
  puts calculate_score(scores)
end

#main
