#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

def run_wc_command(file_path:nil , line_format: false, input_command: nil)
  if file_path.nil?

  else
    concat_wc_contents file_path.to_s
  end

end

def concat_wc_contents(file_path)
  sentence = File.open(file_path).read
  count_lines(sentence).rjust(8) + count_words(sentence).rjust(8) + count_bytes(sentence).rjust(8) + " " +file_path
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

#run_wc_command file_path: "test/sample_dir/sample.rb"
#run_wc_command(file_path: './test/sample_dir/sample.rb')
