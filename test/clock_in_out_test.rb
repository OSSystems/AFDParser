require 'test_helper'
require 'afd_parser'

class ClockInOutTest < Test::Unit::TestCase
  TEMPLATE = "0000000073190220111814111111111111"

  def test_equal
    # equal
    assert AfdParser::ClockInOut.new(TEMPLATE) == AfdParser::ClockInOut.new(TEMPLATE)

    # different record types:
    assert !(AfdParser::ClockInOut.new(TEMPLATE) == AfdParser::SetTime.new("0000000014280120111112280120111113"))

    # different id:
    assert !(AfdParser::ClockInOut.new(TEMPLATE) == AfdParser::ClockInOut.new("0000000083190220111814111111111111"))

    # different time:
    assert !(AfdParser::ClockInOut.new(TEMPLATE) == AfdParser::ClockInOut.new("0000000073190220111815111111111111"))

    # different PIS:
    assert !(AfdParser::ClockInOut.new(TEMPLATE) == AfdParser::ClockInOut.new("0000000073190220111814111111111112"))
  end

  def test_parse_11_digit_pis
    line = "000000007319022011181411111111111\r\n"
    cio = AfdParser::ClockInOut.new line
    assert_equal 7, cio.line_id
    assert_equal 3, cio.record_type_id
    assert_equal Time.local(2011,2,19,18,14), cio.creation_time
    assert_equal 11111111111, cio.pis
  end
end
