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

  # シンボルの配列を用意して、each_with_objectでハッシュを返す。
  # https://docs.ruby-lang.org/ja/latest/method/Enumerable/i/each_with_object.html
  # sendメソッドで引数で渡したメソッドの実行結果を取得。式展開でハッシュキーを用いることでループ処理する
  # https://docs.ruby-lang.org/ja/latest/method/Object/i/send.html
  # シンボル配列であることをわかりやすくするように%記法を用いる(rubocop指摘)
  # https://docs.ruby-lang.org/ja/latest/doc/spec=2fliteral.html#percent
  %i[line word byte].each_with_object({}) { |key, result| result[key] = send("count_#{key}s", sentence) }
end

def concat_hash_contents(content: nil, file_path: nil, l_option: false)
  wc_contents = content[:line].to_s.rjust(8)
  wc_contents += content[:word].to_s.rjust(8) + content[:byte].to_s.rjust(8) unless l_option
  wc_contents += " #{file_path}" unless file_path.nil?
  wc_contents
end

def sum_contents_size(total_size, hash_content)
  # count_wc_contentsの使い方と同じ
  %i[line word byte].each_with_object({}) do |key, result|
    result[key] = total_size[key] + hash_content[key]
  end
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
