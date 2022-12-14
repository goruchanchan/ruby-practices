# frozen_string_literalong: true

require 'minitest/autorun'
require_relative '../lib/input'
require_relative '../lib/formatter'

class LsCommandTest < Minitest::Test
  def test_file_no_option
    expected = <<~TEXT.chomp
      Gemfile       Gemfile.lock
    TEXT
    input = Input.new(paths: %w[Gemfile Gemfile.lock], option_all: false, option_reverse: false)
    assert_equal expected, Formatter.new(groups: input.groups, option_long: false).to_s
  end

  def test_file_r_option
    expected = <<~TEXT.chomp
      Gemfile.lock  Gemfile
    TEXT
    input = Input.new(paths: %w[Gemfile Gemfile.lock], option_all: false, option_reverse: true)
    assert_equal expected, Formatter.new(groups: input.groups, option_long: false).to_s
  end

  def test_file_l_option
    expected = <<~TEXT.chomp
      -rw-r--r--  1 ryo  staff  141 11 29 21:52 Gemfile
      -rw-r--r--  1 ryo  staff  878 11 25 23:38 Gemfile.lock
    TEXT
    input = Input.new(paths: %w[Gemfile Gemfile.lock], option_all: false, option_reverse: false)
    assert_equal expected, Formatter.new(groups: input.groups, option_long: true).to_s
  end

  def test_file_rl_option
    expected = <<~TEXT.chomp
      -rw-r--r--  1 ryo  staff  878 11 25 23:38 Gemfile.lock
      -rw-r--r--  1 ryo  staff  141 11 29 21:52 Gemfile
    TEXT
    input = Input.new(paths: %w[Gemfile Gemfile.lock], option_all: false, option_reverse: true)
    assert_equal expected, Formatter.new(groups: input.groups, option_long: true).to_s
  end

  def test_directory_no_option
    expected = <<~TEXT.chomp
      Gemfile         bin             test
      Gemfile.lock    lib
    TEXT
    input = Input.new(paths: %w[.], option_all: false, option_reverse: false)
    assert_equal expected, Formatter.new(groups: input.groups, option_long: false).to_s
  end

  # def test_directory_r_option
  #   expected = <<~TEXT.chomp
  #     test            bin             Gemfile
  #     lib             Gemfile.lock
  #   TEXT
  #   input = Input.new(paths: %w[.], option_all: false, option_reverse: true)
  #   assert_equal expected, Formatter.new(groups: input.groups, option_long: false).to_s
  # end

  # def test_directory_l_option
  #   expected = <<~TEXT.chomp
  #     total 8
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 1
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 1.rb
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 10
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 1111.rb
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 2
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 3
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 4
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 5
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 6
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 7
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 8
  #     -rw-r--r--   1 ryo  staff   10 11 25 21:52 9
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 a.rb
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:52 bbbb.rb
  #     drwxr-xr-x  13 ryo  staff  416 11 25 21:53 child_dir
  #   TEXT
  #   input_dir = InputData.new(%w[test/test_data], { all: false, long: true, reverse: false })
  #   assert_equal expected, LsDirectory.new(input_dir).ls
  # end

  # def test_directory_a_option
  #   expected = <<~TEXT.chomp
  #     .               Gemfile         lib
  #     ..              Gemfile.lock    test
  #     .rubocop.yml    bin
  #   TEXT
  #   input_dir = InputData.new(%w[.], { all: true, long: false, reverse: false })
  #   assert_equal expected, LsDirectory.new(input_dir).ls
  # end

  # def test_directory_rla_option
  #   expected = <<~TEXT.chomp
  #     total 0
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 9
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 8
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 7
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 6
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 5
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 4
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 3
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 2
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 11
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 10
  #     -rw-r--r--   1 ryo  staff    0 11 25 21:53 1
  #     drwxr-xr-x  18 ryo  staff  576 11 25 22:28 ..
  #     drwxr-xr-x  13 ryo  staff  416 11 25 21:53 .
  #   TEXT
  #   input_dir = InputData.new(%w[test/test_data/child_dir], { all: true, long: true, reverse: true })
  #   assert_equal expected, LsDirectory.new(input_dir).ls
  # end
end
