require 'test_helper'
require 'afd_parser'

class SetEmployeeTest < Test::Unit::TestCase
  def test_parsing
    # normal 12 digits:
    record = AfdParser::SetEmployee.new("0000000045080220111709I222222222222FULANO DE TAL                                       ")
    assert_equal 222222222222, record.pis
    assert_equal 4, record.line_id
    assert_equal 5, record.record_type_id
    assert_equal DateTime.civil(2011,2,8,19,9).to_time, record.creation_time
    assert_equal :add, record.operation_type
    assert_equal "FULANO DE TAL", record.name

    # normal 11 digits:
    record = AfdParser::SetEmployee.new("0000000045080220111709I22222222222FULANO DE TAL                                       ")
    assert_equal 22222222222, record.pis
    assert_equal 4, record.line_id
    assert_equal 5, record.record_type_id
    assert_equal DateTime.civil(2011,2,8,19,9).to_time, record.creation_time
    assert_equal :add, record.operation_type
    assert_equal "FULANO DE TAL", record.name

    # error: 1 zero digit:
    record = AfdParser::SetEmployee.new("0000000045080220111709I0FULANO DE TAL                                       ")
    assert_equal 0, record.pis
    assert_equal 4, record.line_id
    assert_equal 5, record.record_type_id
    assert_equal DateTime.civil(2011,2,8,19,9).to_time, record.creation_time
    assert_equal :add, record.operation_type
    assert_equal "FULANO DE TAL", record.name
  end

  def test_equal
    template = "0000000045080220111709I222222222222TESTE 2                                             ".freeze
    # equal
    assert AfdParser::SetEmployee.new(template) == AfdParser::SetEmployee.new(template)

    # different record types:
    assert !(AfdParser::SetEmployee.new(template) == AfdParser::SetTime.new("0000000014280120111112280120111113"))

    # different id:
    assert !(AfdParser::SetEmployee.new(template) == AfdParser::SetEmployee.new("0000000055080220111709I222222222222TESTE 2                                             "))

    # different time:
    assert !(AfdParser::SetEmployee.new(template) == AfdParser::SetEmployee.new("0000000045080220121709I222222222222TESTE 2                                             "))

    # different operation:
    assert !(AfdParser::SetEmployee.new(template) == AfdParser::SetEmployee.new("0000000045080220111709A222222222222TESTE 2                                             "))

    # different PIS:
    assert !(AfdParser::SetEmployee.new(template) == AfdParser::SetEmployee.new("0000000045080220111709I333333333333TESTE 2                                             "))

    # different name:
    assert !(AfdParser::SetEmployee.new(template) == AfdParser::SetEmployee.new("0000000045080220111709I222222222222FULANO DE TAL                                       "))
  end
end
