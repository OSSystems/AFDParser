require 'test_helper'
require 'afd_parser'

class SetEmployerTest < Test::Unit::TestCase
  TEMPLATE = "0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "

  def test_equal
    # equal
    assert AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new(TEMPLATE)

    # different record types:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetTime.new("0000000014280120111112280120111113"))

    # different id:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000032270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "))
    # different time:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000022270120121756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "))
    # different document type:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000022270120111756208682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "))
    # different document number:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000022270120111756111111111111111000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "))
    # different CEI:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000022270120111756108682040000172222222222222O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "))
    # different name:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000022270120111756108682040000172000000000000SUPER COMPANY INCORPORATED                                                                                                                            PELOTAS - RS                                                                                        "))
    # different location:
    assert !(AfdParser::SetEmployer.new(TEMPLATE) == AfdParser::SetEmployer.new("0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          NEVERLAND - DISNEYLAND                                                                              "))
  end
end
