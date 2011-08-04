require 'test_helper'
require 'afd_parser'

class SetEmployeeTest < Test::Unit::TestCase
  TEMPLATE = "0000000045080220111709I222222222222TESTE 2                                             "

  def test_equal
    # equal
    assert AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetEmployee.new(TEMPLATE)

    # different record types:
    assert !(AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetTime.new("0000000014280120111112280120111113"))

    # different id:
    assert !(AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetEmployee.new("0000000055080220111709I222222222222TESTE 2                                             "))

    # different time:
    assert !(AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetEmployee.new("0000000045080220121709I222222222222TESTE 2                                             "))

    # different operation:
    assert !(AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetEmployee.new("0000000045080220111709A222222222222TESTE 2                                             "))

    # different PIS:
    assert !(AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetEmployee.new("0000000045080220111709I333333333333TESTE 2                                             "))

    # different name:
    assert !(AfdParser::SetEmployee.new(TEMPLATE) == AfdParser::SetEmployee.new("0000000045080220111709I222222222222FULANO DE TAL                                       "))
  end
end
