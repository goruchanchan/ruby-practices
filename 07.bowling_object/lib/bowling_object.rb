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

  def frame_score
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

class Game
  attr_reader :frames, :total_down_marks, :total_additional_marks
  def initialize
    @frames = []
    @total_score = 0
    @total_down_marks = 0
    @total_additional_marks = 0
  end

  def consist_game(shots)
    frame_shots = []
    shots.each_with_index do |s, i|
      frame_shots << s
      if @frames.size < 9 # 〜9投目
        if frame_shots.size % 2 == 0 || s.score == 10
          @frames << Frame.new(frame_shots)
          frame_shots.clear
        end
      else # 10投目
        @frames << Frame.new(frame_shots) if (shots.length - 1) == i
      end
    end
  end

  def sum_down_marks
    @frames.each do |frame|
      @total_down_marks += frame.frame_score
    end
    @total_down_marks
  end

  def sum_additional_marks
    frames.each_with_index do |frame,i|
       if i < 9 
        case frame.frame_type
        when :strike
          @total_additional_marks += if (frames[i + 1].frame_type == :strike && i < 8)
            frames[i + 1].score_2shots + frames[i + 2].score_1shot
          else
            frames[i + 1].score_2shots
          end
        when :spare
          @total_additional_marks += frames[i + 1].score_1shot
        end
      end
    end
  end

  def game_score
    @total_down_marks + @total_additional_marks
  end
end

def calculate_score(input)
  shots = input.map { |s| Shot.new(s) }

  game = Game.new()
  game.consist_game(shots)
  game.sum_down_marks
  game.sum_additional_marks
  game.game_score
end

def main
  scores = ARGV[0].split(',')
  puts calculate_score(scores)
end
