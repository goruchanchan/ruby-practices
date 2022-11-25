require 'minitest/autorun'
require_relative '../lib/ls1'

class LsTest < Minitest::Test
  def test_ls_input_no_path
    assert_equal 'lib     test    ', list_segment('')
  end

  def test_ls_input_path
    expected = <<~TEXT
    1 5 9
    2 6 10
    3 7
    4 8
    TEXT
    assert_equal expected, list_segment('test_dir/')
  end

  def test_ls_input_error_path
    assert_equal 'ls: hoge: No such file or directory    ', list_segment('hoge/')
  end
end
