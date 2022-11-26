# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsCommandTest < Minitest::Test
  def test_not_exist
    expected = <<~TEXT.chomp
      ls: foo: No such file or directory
      ls: hoge: No such file or directory
    TEXT
    assert_equal expected, error_message(["foo", "hoge"])
  end

  # def test_ls
  #   expected = <<~TEXT.chomp
  #     Gemfile       bin           lib
  #     Gemfile.lock  doc           test
  #   TEXT
  #   assert_equal expected, print_directories({:path=>".", :file_list=>["Gemfile", "Gemfile.lock", "bin", "doc", "lib", "test"]}, {:file=>[], :directory=>["."], :error=>[], :option=>[]})
  # end

  # def test_ls_input_path
  #   expected = <<~TEXT
  #   1 5 9
  #   2 6 10
  #   3 7
  #   4 8
  #   TEXT
  #   assert_equal expected, main('sample_dir/hoge')
  # end

  # def test_ls_input_error_path
  #   assert_equal 'ls: hoge: No such file or directory    ', main('hoge/')
  # end
end
