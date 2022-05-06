#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

def run_wc(file_path: nil, sentence: nil, l_option: false)
  if sentence.nil?
    "wc: #{file_path}: open: No such file or directory"
  else
    concat_wc_contents(file_path, l_option, sentence)
  end
end

def concat_wc_contents(file_path, l_option, sentence)
  lines_cnt = count_lines(sentence)
  words_cnt = count_words(sentence)
  bytes_cnt = count_bytes(sentence)

  wc_contents = lines_cnt.rjust(8)
  wc_contents += words_cnt.rjust(8) + bytes_cnt.rjust(8) unless l_option
  wc_contents << " #{file_path}" unless file_path.nil?
  wc_contents
end

def count_lines(sentence)
  # https://docs.ruby-lang.org/ja/latest/method/String/i/count.html
  lines = sentence.count("\n")
  lines += 1 if sentence.match?(/[^\n]\z/)
  lines.to_s
end

def count_words(sentence)
  # 単語の区切りの空白文字は半角スペース、タブ、改行程度
  sentence.split.size.to_s
end

def count_bytes(sentence)
  sentence.size.to_s
end

def get_total_size(contents, params)
  total = { line: 0, word: 0, byte: 0 }
  contents.each do |content|
    total[:line] += content.split[0].to_i
    total[:word] += content.split[1].to_i
    total[:byte] += content.split[2].to_i
  end
  if params[:l_option]
    "#{total_line.rjust(8)} total"
  else
    "#{total[:line].to_s.rjust(8)}#{total[:word].to_s.rjust(8)}#{total[:byte].to_s.rjust(8)} total"
  end
end
