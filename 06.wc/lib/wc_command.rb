#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

TOTAL_SIZE = {words: 0, lines: 0, bytes: 0}

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

  TOTAL_SIZE[:lines] += lines_cnt.to_i
  wc_contents = lines_cnt.rjust(8)
  unless l_option
    TOTAL_SIZE[:words] += words_cnt.to_i
    TOTAL_SIZE[:bytes] += bytes_cnt.to_i
    wc_contents += words_cnt.rjust(8) + bytes_cnt.rjust(8)
  end
  wc_contents += " " +  file_path.to_s unless file_path.nil?
  wc_contents
end

def get_total_size(params)
  if params[:l_option]
    "#{TOTAL_SIZE[:lines].to_s.rjust(8)} total"
  else
    "#{TOTAL_SIZE[:lines].to_s.rjust(8)} #{TOTAL_SIZE[:words].to_s.rjust(8)} #{TOTAL_SIZE[:bytes].to_s.rjust(8)} total"
  end
end

def count_lines(sentence)
  # https://docs.ruby-lang.org/ja/latest/method/String/i/count.html
  lines = sentence.count("\n")
  lines += 1 if /[^\n]\z/ =~ sentence
  lines.to_s
end

def count_words(sentence)
  # 単語の区切りの空白文字は半角スペース、タブ、改行程度
  sentence.split.size.to_s
end

def count_bytes(sentence)
  sentence.size.to_s
end

# TARGET_FILE_PATH = Pathname('./test/sample_dir/sample.rb')
# puts run_wc_command(file_path: TARGET_FILE_PATH)

