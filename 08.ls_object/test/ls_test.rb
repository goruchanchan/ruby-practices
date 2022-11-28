# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/file'
require_relative '../lib/directory'

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
      total 8
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 1
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 1.rb
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 10
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 1111.rb
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 2
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 3
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 4
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 5
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 6
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 7
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 8
      -rw-r--r--   1 ryo  staff   10 11 25 21:52 9
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 a.rb
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 bbbb.rb
      drwxr-xr-x  13 ryo  staff  416 11 25 21:53 child_dir
    TEXT
    assert_equal expected, ls_directories(%w[test/test_data], %w[-l], 13)
  end

  def test_directory_a_option
    expected = <<~TEXT.chomp
      .               Gemfile         doc
      ..              Gemfile.lock    lib
      .rubocop.yml    bin             test
    TEXT
    assert_equal expected, ls_directories(%w[.], %w[-a], 13)
  end

  def test_directory_rla_option
    expected = <<~TEXT.chomp
      total 8
      drwxr-xr-x  13 ryo  staff  416 11 25 21:53 child_dir
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 bbbb.rb
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 a.rb
      -rw-r--r--   1 ryo  staff   10 11 25 21:52 9
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 8
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 7
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 6
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 5
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 4
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 3
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 2
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 1111.rb
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 10
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 1.rb
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 1
      -rw-r--r--   1 ryo  staff    0 11 25 21:52 .test
      drwxr-xr-x   4 ryo  staff  128 11 25 23:38 ..
      drwxr-xr-x  18 ryo  staff  576 11 25 22:28 .
    TEXT
    assert_equal expected, ls_directories(%w[test/test_data], %w[-l -a -r], 13)
  end
end
