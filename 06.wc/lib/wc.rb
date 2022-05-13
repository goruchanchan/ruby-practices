#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'optparse'
require './lib/wc_command'

def main
  params = { l_option: false }
  opt = OptionParser.new
  opt.on('-l') { |v| params[:l_option] = v }
  opt.parse!(ARGV)

  if ARGV.empty?
    hash_content = run_wc(sentence: $stdin.read)
    puts concat_hash_contents(content: hash_content, **params)
  else
    total_size = { line: 0, word: 0, byte: 0 }
    ARGV.each do |file_path|
      if FileTest.exist?(file_path)
        hash_content = run_wc(sentence: File.open(file_path).read, file_path: Pathname(file_path), **params)
        puts concat_hash_contents(content: hash_content, file_path: Pathname(file_path), **params)
        total_size = sum_contents_size(total_size, hash_content)
      else
        puts "wc: #{Pathname(file_path)}: open: No such file or directory"
      end
    end
    puts calculate_total_size(total_size, params) if ARGV.size > 1
  end
end

main
