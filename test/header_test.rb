require 'test_helper'
require 'afd_parser'

class HeaderTest < Test::Unit::TestCase
  TEMPLATE = "0000000001200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048"

  def test_equal
    # equal
    assert AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new(TEMPLATE)

    # different record types:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::SetTime.new("0000000024280120111112280120111113"))

    # different id:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000011200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048"))

    # different employer type:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048"))

    # different employer document:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001200000000567890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048"))

    # different employer cei:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001200000000067890000000019876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048"))

    # different employer name:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001200000000067890000000009876RACAO_SOCIAL                                                                                                                                          111141111711144132001201122022011210220111048"))

    # different start date:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032000201122022011210220111048"))

    # different end date:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022012210220111048"))

    # different afd creation time:
    assert !(AfdParser::Header.new(TEMPLATE) == AfdParser::Header.new("0000000001200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220121048"))

  end

  def test_corrupted_date_parsing
    # corrupted times:
    header = AfdParser::Header.new("0000000001200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044034001201132022011320220121048")
    assert_equal '40012011', header.afd_start_date
    assert_equal '32022011', header.afd_end_date
    assert_equal '320220121048', header.afd_creation_time
  end
end
