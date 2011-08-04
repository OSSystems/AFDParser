require 'test_helper'
require 'afd_parser'

class SetTimeTest < Test::Unit::TestCase
  TEMPLATE = "0000000014280120111112280120111113"

  def test_equal
    # equal
    assert AfdParser::SetTime.new(TEMPLATE) == AfdParser::SetTime.new(TEMPLATE)

    # different record types:
    assert !(AfdParser::SetTime.new(TEMPLATE) == AfdParser::ClockInOut.new("0000000014280120111112280120111113"))

    # different id:
    assert !(AfdParser::SetTime.new(TEMPLATE) == AfdParser::SetTime.new("0000000024280120111112280120111113"))

    # different before time:
    assert !(AfdParser::SetTime.new(TEMPLATE) == AfdParser::SetTime.new("0000000014280120121112280120111113"))

    # different after time:
    assert !(AfdParser::SetTime.new(TEMPLATE) == AfdParser::SetTime.new("0000000014280120111112280120121113"))
  end
end
