#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'
require './lib/wc_command'

class WcCommandTest < Minitest::Test
  TARGET_FILE_PATH = Pathname('./test/sample_dir/sample.rb')

  def test_file
    expected = `wc #{TARGET_FILE_PATH}`.chomp
    assert_equal expected, test_run_wc(file_path: TARGET_FILE_PATH, sentence: File.open(TARGET_FILE_PATH).read)
  end

  def test_file_l_option
    expected = `wc -l #{TARGET_FILE_PATH}`.chomp
    assert_equal expected, test_run_wc(file_path: TARGET_FILE_PATH, sentence: File.open(TARGET_FILE_PATH).read, l_option: true)
  end

  def test_standard_io
    expected = `echo "123\n45\nab\ncdef"|wc`.chomp
    assert_equal expected, test_run_wc(sentence: "123\n45\nab\ncdef\n") # echoで呼び出すと最終行に改行が含まれるので入れる
  end

  def test_ls_comannd
    expected = `ls -l #{TARGET_FILE_PATH}|wc`.chomp
    assert_equal expected, test_run_wc(sentence: "-rw-r--r--  1 ryo  staff  31  4 29 07:34 ./test/sample_dir/sample.rb\n")# パイプで渡すと改行が挿入されるので入れる
  end

  # def test_usr_ls_comannd
  #   expected = `ruby /Users/ryo/fjord/ruby-practices/05.ls/lib/ls5.rb -l #{TARGET_FILE_PATH}|wc`.chomp# 自分で作ったパスに変更
  #   p expected
  #   assert_equal expected, test_run_wc(sentence: "-rw-r--r--  1 ryo  staff  31  4 29 07:34 ./test/sample_dir/sample.rb \n")# 自分のlsコマンドだと最終文字に空白が入っていた、、、
  # end

end
