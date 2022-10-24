#!/usr/bin/env ruby
# frozen_string_literal: true

class Shot
  def initialize(mark)
    @mark = mark
  end
  def get_shot_score
    @mark == 'X' ? 10 : @mark.to_i
  end
end

class Frame
  def initialize(frame_shots)
    @first_shot = frame_shots[0]
    @second_shot = frame_shots[1] unless frame_shots[1].nil?
    @third_shot = frame_shots[2] unless frame_shots[2].nil?
  end

  def get_score_1shot
    @first_shot.get_shot_score
  end

  def get_score_2shots
    @second_shot.nil? ? get_score_1shot : get_score_1shot + @second_shot.get_shot_score
  end

  def get_frame_score
    @third_shot.nil? ? get_score_2shots : get_score_2shots + @third_shot.get_shot_score
  end

  def get_frame_type
    return :strike if get_score_1shot == 10
    return :spare if get_score_2shots == 10
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
      if @frames.size < 9 # 〜9投目
        if frame_shots.size % 2 == 0 || shot.get_shot_score == 10
          @frames << Frame.new(frame_shots)
          frame_shots.clear
        end
      elsif(shots.length - 1 == i) # 10投目
        @frames << Frame.new(frame_shots)
      end
    end
  end

  def sum_down_marks
    @frames.each do |frame|
      @total_marks += frame.get_frame_score
    end
  end

  def sum_additional_marks
    @frames.each_with_index do |frame,i|
       if i < 9 
        case frame.get_frame_type
        when :strike
          @total_marks += @frames[i + 1].get_score_2shots
          # 9フレームにストライクで、10フレームでストライクを取っても次のフレームには移動しない
          @total_marks += @frames[i + 2].get_score_1shot if @frames[i + 1].get_frame_type == :strike && i < 8
        when :spare
          @total_marks += @frames[i + 1].get_score_1shot
        end
      end
    end
  end

  def get_game_score
    sum_down_marks
    sum_additional_marks
    @total_marks
  end
end

def calculate_score(input)
  Game.new( input.map { |shot| Shot.new(shot) } ).get_game_score
end

def main
  scores = ARGV[0].split(',')
  puts calculate_score(scores)
end

#main
