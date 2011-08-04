require 'test_helper'
require 'afd_parser'

class TrailerTest < Test::Unit::TestCase
  TEMPLATE = ["9999999990000000010000000030000000010000000049", {:set_employer => 1, :clock_in_out => 3, :set_time => 1, :set_employee => 4}]

  def test_equal
    # equal
    assert AfdParser::Trailer.new(*TEMPLATE) == AfdParser::Trailer.new(*TEMPLATE)

    # different record types:
    assert !(AfdParser::Trailer.new(*TEMPLATE) == AfdParser::SetTime.new("0000000014280120111112280120111113"))

    # different set employer count:
    assert !(AfdParser::Trailer.new(*TEMPLATE) == AfdParser::Trailer.new("9999999990000000020000000030000000010000000049", {:set_employer => 2, :clock_in_out => 3, :set_time => 1, :set_employee => 4}))

    # different clock_in_out count:
    assert !(AfdParser::Trailer.new(*TEMPLATE) == AfdParser::Trailer.new("9999999990000000010000000040000000010000000049", {:set_employer => 1, :clock_in_out => 4, :set_time => 1, :set_employee => 4}))

    # different set_time count:
    assert !(AfdParser::Trailer.new(*TEMPLATE) == AfdParser::Trailer.new("9999999990000000010000000030000000020000000049", {:set_employer => 1, :clock_in_out => 3, :set_time => 2, :set_employee => 4}))

    # different:
    assert !(AfdParser::Trailer.new(*TEMPLATE) == AfdParser::Trailer.new("9999999990000000010000000030000000010000000059", {:set_employer => 1, :clock_in_out => 3, :set_time => 1, :set_employee => 5}))
  end
end
