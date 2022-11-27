# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsCommandTest < Minitest::Test
  def test_not_exist
    expected = <<~TEXT.chomp
      ls: foo: No such file or directory
      ls: hoge: No such file or directory
    TEXT
    assert_equal expected, error_message(%w[foo hoge])
  end

  def test_file_no_option
    expected = <<~TEXT.chomp
      Gemfile       Gemfile.lock
    TEXT
    assert_equal expected, ls_files(%w[Gemfile Gemfile.lock], %w[], 13)
  end

  def test_file_r_option
    expected = <<~TEXT.chomp
      Gemfile.lock  Gemfile
    TEXT
    assert_equal expected, ls_files(%w[Gemfile Gemfile.lock], %w[-r], 13)
  end

  def test_file_l_option
    expected = <<~TEXT.chomp
      -rw-r--r--  1 ryo  staff  141 11 25 23:38 Gemfile
      -rw-r--r--  1 ryo  staff  878 11 25 23:38 Gemfile.lock
    TEXT
    assert_equal expected, ls_files(%w[Gemfile Gemfile.lock], %w[-l], 13)
  end

  def test_file_rl_option
    expected = <<~TEXT.chomp
      -rw-r--r--  1 ryo  staff  878 11 25 23:38 Gemfile.lock
      -rw-r--r--  1 ryo  staff  141 11 25 23:38 Gemfile
    TEXT
    assert_equal expected, ls_files(%w[Gemfile Gemfile.lock], %w[-l -r], 13)
  end

  def test_directory_no_option
    expected = <<~TEXT.chomp
      Gemfile         bin             lib
      Gemfile.lock    doc             test
    TEXT
    assert_equal expected, ls_directories(%w[.], %w[], 13)
  end

  def test_directory_r_option
    expected = <<~TEXT.chomp
      test            doc             Gemfile.lock
      lib             bin             Gemfile
    TEXT
    assert_equal expected, ls_directories(%w[.], %w[-r], 13)
  end

  def test_directory_l_option
    expected = <<~TEXT.chomp
      total 16
      -rw-r--r--  1 ryo  staff  141 11 25 23:38 Gemfile
      -rw-r--r--  1 ryo  staff  878 11 25 23:38 Gemfile.lock
      drwxr-xr-x  3 ryo  staff   96 11 25 22:37 bin
      drwxr-xr-x  3 ryo  staff   96 11 25 21:52 doc
      drwxr-xr-x  5 ryo  staff  160 11 26 16:24 lib
      drwxr-xr-x  4 ryo  staff  128 11 25 23:38 test
    TEXT
    assert_equal expected, ls_directories(%w[.], %w[-l], 13)
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
