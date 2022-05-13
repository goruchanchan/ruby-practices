#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

def run_wc(sentence: nil)
  count_wc_contents(sentence)
end

def test_run_wc(file_path: nil, sentence: nil, l_option: false)
  hash_content = count_wc_contents(sentence)
  concat_hash_contents(content: hash_content, file_path: file_path, l_option: l_option)
end

def count_wc_contents(sentence)
  return nil if sentence.nil?

  { line: count_lines(sentence), word: count_words(sentence), byte: count_bytes(sentence) }
end

def concat_hash_contents(content: nil, file_path: nil, l_option: false)
  wc_contents = content[:line].to_s.rjust(8)
  wc_contents += content[:word].to_s.rjust(8) + content[:byte].to_s.rjust(8) unless l_option
  wc_contents += " #{file_path}" unless file_path.nil?
  wc_contents
end

def sum_contents_size(total_size, hash_content)
  line = total_size[:line] + hash_content[:line]
  word = total_size[:word] + hash_content[:word]
  byte = total_size[:byte] + hash_content[:byte]
  { line: line, word: word, byte: byte }
end

def count_lines(sentence)
  # https://docs.ruby-lang.org/ja/latest/method/String/i/count.html
  lines = sentence.count("\n")
  lines += 1 if sentence.match?(/[^\n]\z/)
  lines
end

def count_words(sentence)
  # 単語の区切りの空白文字は半角スペース、タブ、改行程度
  sentence.split.size
end

def count_bytes(sentence)
  sentence.size
end

def calculate_total_size(total, params)
  return "#{total[:line].to_s.rjust(8)} total" if params[:l_option]

  "#{total[:line].to_s.rjust(8)}#{total[:word].to_s.rjust(8)}#{total[:byte].to_s.rjust(8)} total"
end
