#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require './lib/wc_command'
require 'pathname'

class WcCommandTest < Minitest::Test
  TARGET_FILE_PATH = Pathname('./test/sample_dir/sample.rb')
  TARGET_FILES_PATH = './test/sample_dir/sample.rb  ./test/sample_dir/9'

  def test_file
    expected = `wc #{TARGET_FILE_PATH}`.chomp
    assert_equal expected, run_wc_command(file_path: './test/sample_dir/sample.rb')
  end

  # def test_file_l_option
  #   expected = `wc -l #{TARGET_FILE_PATH}`
  #   assert_equal expected, run_wc_command(file_path: TARGET_FILE_PATH, line_format: true)
  # end

  # def test_standard_io
  #   expected = `echo "123\n45\nab\ncdef" | wc`
  #   assert_equal expected, run_wc_command(line_format: 'echo "123\n45\nab\ncdef"')
  # end

  # def test_files
  #   expected = `wc #{TARGET_FILES_PATH}`
  #   assert_equal expected, run_wc_command
  # end

  # def test_usr_ls_comannd
  #   expected = `ls -l #{TARGET_FILE_PATH}|wc`# 自分で作ったパスに変更
  #   assert_equal expected, run_wc_command
  # end

  # def test_ls_comannd
  #   expected = `ls -l #{TARGET_FILE_PATH}|wc`
  #   assert_equal expected, run_wc_command(input_command: '-l')
  # end
end
