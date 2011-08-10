# -*- coding: utf-8 -*-
# Controle de Horas - Sistema para gestão de horas trabalhadas
# Copyright (C) 2009  O.S. Systems Softwares Ltda.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Rua Clóvis Gularte Candiota 132, Pelotas-RS, Brasil.
# e-mail: contato@ossystems.com.br

require File.dirname(__FILE__) + '/./test_helper'
require 'tempfile'
require 'afd_parser'

class AfdParserTest < Test::Unit::TestCase
  def test_parse_file_one_line_at_the_time
    parser = AfdParser.new(true)
    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser.parse_line(line, index)
    end
    file.close

    parsed_records = parser.records
    assert_equal 9, parsed_records.size

    assert_equal 0, parser.header.line_id
    assert_equal 1, parser.header.record_type_id
    assert_equal :cnpj, parser.header.employer_type
    assert_equal Time.local(2011,2,21,10,48), parser.header.afd_creation_time
    assert_equal Date.civil(2011,1,20), parser.header.afd_start_date
    assert_equal Date.civil(2011,2,22), parser.header.afd_end_date
    assert_equal "00004000070004403", parser.header.rep_serial_number
    assert_equal "RAZAO_SOCIAL", parser.header.employer_name
    assert_equal 67890, parser.header.employer_document
    assert_equal 9876, parser.header.employer_cei

    set_time = parsed_records[0]
    assert_equal 1, set_time.line_id
    assert_equal Time.local(2011,1,28,11,13), set_time.after_time
    assert_equal Time.local(2011,1,28,11,12), set_time.before_time
    assert_equal 4, set_time.record_type_id

    set_employer = parsed_records[1]
    assert_equal 8682040000172, set_employer.document_number
    assert_equal 2, set_employer.line_id
    assert_equal "PELOTAS - RS", set_employer.location
    assert_equal :cnpj, set_employer.document_type
    assert_equal Time.local(2011,1,27,17,56), set_employer.creation_time
    assert_equal 0, set_employer.cei
    assert_equal "O.S. SYSTEMS SOFTWARES LTDA.", set_employer.name
    assert_equal 2, set_employer.record_type_id

    set_employee = parsed_records[2]
    assert_equal 111111111111, set_employee.pis
    assert_equal 3, set_employee.line_id
    assert_equal :add, set_employee.operation_type
    assert_equal Time.local(2011,1,27,17,59), set_employee.creation_time
    assert_equal "TESTE 1 2 3", set_employee.name
    assert_equal 5, set_employee.record_type_id

    set_employee = parsed_records[3]
    assert_equal 222222222222, set_employee.pis
    assert_equal 4, set_employee.line_id
    assert_equal :add, set_employee.operation_type
    assert_equal Time.local(2011,2,8,17,9), set_employee.creation_time
    assert_equal "TESTE 2", set_employee.name
    assert_equal 5, set_employee.record_type_id

    set_employee = parsed_records[4]
    assert_equal 222222222222, set_employee.pis
    assert_equal 5, set_employee.line_id
    assert_equal :edit, set_employee.operation_type
    assert_equal Time.local(2011,2,11,17,19), set_employee.creation_time
    assert_equal "TESTE 2", set_employee.name
    assert_equal 5, set_employee.record_type_id

    set_employee = parsed_records[5]
    assert_equal 222222222222, set_employee.pis
    assert_equal 6, set_employee.line_id
    assert_equal :remove, set_employee.operation_type
    assert_equal Time.local(2011,2,11,17,23), set_employee.creation_time
    assert_equal "TESTE 2", set_employee.name
    assert_equal 5, set_employee.record_type_id

    clock_in_out = parsed_records[6]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 7, clock_in_out.line_id
    assert_equal Time.local(2011,2,19,18,14), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    clock_in_out = parsed_records[7]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 8, clock_in_out.line_id
    assert_equal Time.local(2011,2,21,11,33), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    clock_in_out = parsed_records[8]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 9, clock_in_out.line_id
    assert_equal Time.local(2011,2,21,11,34), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    assert_equal 3, parser.trailer.clock_in_out
    assert_equal 999999999, parser.trailer.line_id
    assert_equal 1, parser.trailer.set_employer
    assert_equal 4, parser.trailer.set_employee
    assert_equal 1, parser.trailer.set_time
    assert_equal 9, parser.trailer.record_type_id
  end

  def test_export_simple_file
    file_data = nil
    File.open("test/afd_file", "r") do |f|
      file_data = f.readlines.join("")
    end
    parser = AfdParser.new("test/afd_file", true)
    parser.parse
    assert_equal file_data, parser.export
  end

  def test_file_one_line_at_the_time_with_created_header_and_trailer
    line = "0000000014280120111112280120111113\n"
    parser = AfdParser.new(true)
    time = Time.now
    parser.create_header(:cnpj, 12345678901234, 0, "Company name", "12345678901234567", Date.today, Date.today, time)
    parser.parse_line(line, 1)
    parser.create_trailer
    parsed_records = parser.records
    assert_equal 1, parsed_records.size

    assert_equal 0, parser.header.line_id
    assert_equal 1, parser.header.record_type_id
    assert_equal :cnpj, parser.header.employer_type
    assert_equal time, parser.header.afd_creation_time
    assert_equal Date.today, parser.header.afd_start_date
    assert_equal Date.today, parser.header.afd_end_date
    assert_equal "12345678901234567", parser.header.rep_serial_number
    assert_equal "Company name", parser.header.employer_name
    assert_equal 12345678901234, parser.header.employer_document
    assert_equal 0, parser.header.employer_cei

    set_time = parsed_records[0]
    assert_equal 1, set_time.line_id
    assert_equal Time.local(2011,1,28,11,13), set_time.after_time
    assert_equal Time.local(2011,1,28,11,12), set_time.before_time
    assert_equal 4, set_time.record_type_id

    assert_equal 0, parser.trailer.clock_in_out
    assert_equal 999999999, parser.trailer.line_id
    assert_equal 0, parser.trailer.set_employer
    assert_equal 0, parser.trailer.set_employee
    assert_equal 1, parser.trailer.set_time
    assert_equal 9, parser.trailer.record_type_id
  end

  def test_reject_file_with_out_of_order_line_ids
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000024280120111112280120111113\n" +
      "0000000012270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n" +
      "9999999990000000010000000030000000010000000049"

    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Out-of-order line id on line 1; expected '1', got '2'", exception.message
  end

  def test_reject_file_with_unknown_record_type
    # The second line contains a set_time record, but with type number 8,
    # which doesn't exists:
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000018280120111112280120111113\n" +
      "0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n" +
      "9999999990000000010000000030000000010000000049"

    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unknown record type found in AFD file, line 1: '0000000018280120111112280120111113\n'", exception.message
  end

  def test_reject_file_with_second_header
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000011100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000024280120111112280120111113\n" +
      "9999999990000000000000000000000000010000000009\n"
    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unexpected second AFD header found, line 1: '0000000011100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n'", exception.message
  end

  def test_reject_file_with_data_before_header
    data = "0000000002270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n"+
      "0000000011100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000024280120111112280120111113\n" +
      "9999999990000000000000000000000000010000000009\n"
    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unexpected AFD record found before header, line 0: '0000000002270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n'", exception.message
  end

  def test_reject_file_with_no_trailer
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000014280120111112280120111113\n" +
      "0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "
    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "AFD ended without a trailer record", exception.message
  end

  def test_reject_file_with_data_after_trailer
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000014280120111112280120111113\n" +
      "9999999990000000000000000000000000010000000009\n" +
      "0000000032270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        "
    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unexpected AFD record found after trailer, line 3: '0000000032270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        '", exception.message
  end

  def test_reject_file_with_unknown_employer_type_id_in_header
    data = "0000000001300000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000014280120111112280120111113\n" +
      "0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n" +
      "9999999990000000010000000030000000010000000049"

    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unknown employer type id '3' found in AFD header", exception.message
  end

  def test_reject_file_with_unknown_employee_operation_type_id
    data = "0000000001200000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000014280120111112280120111113\n" +
      "0000000025080220111709C222222222222TESTE 2                                             \n" +
      "9999999990000000000000000010000000010000000019"

    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unknown employee operation type letter 'C' found in line 2", exception.message
  end

  def test_reject_file_with_unknown_employer_type_id
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000014280120111112280120111113\n" +
      "0000000022270120111756308682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n" +
      "9999999990000000010000000000000000010000000009"

    file_path = create_temp_afd_file(data)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Unknown employer type id '3' found in set employer record on line 2", exception.message
  end

  def test_reject_file_with_difference_in_trailer_count_data
    data = "0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048\n" +
      "0000000014280120111112280120111113\n" +
      "0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        \n"
    trailer = "9999999990000000020000000000000000010000000009"

    file_path = create_temp_afd_file(data + trailer)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Mismatch counting changes of set_employer in REP!\nREP: 2 | System: 1", exception.message

    trailer = "9999999990000000010000000010000000010000000009"

    file_path = create_temp_afd_file(data + trailer)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Mismatch counting changes of clock_in_out in REP!\nREP: 1 | System: 0", exception.message

    trailer = "9999999990000000010000000000000000020000000009"

    file_path = create_temp_afd_file(data + trailer)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Mismatch counting changes of set_time in REP!\nREP: 2 | System: 1", exception.message

    trailer = "9999999990000000010000000000000000010000000029"

    file_path = create_temp_afd_file(data + trailer)
    exception = assert_raise AfdParser::AfdParserException do
      parser = AfdParser.new(file_path, true)
      parser.parse
      parsed_records = parser.records
    end
    assert_equal "Mismatch counting changes of set_employee in REP!\nREP: 2 | System: 0", exception.message
  end

  def test_first_creation_date
    parser = AfdParser.new(true)
    assert_nil parser.first_creation_date

    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser.parse_line(line, index)
    end
    file.close

    assert_equal Date.civil(2011,1,28), parser.first_creation_date
  end

  def test_last_creation_date
    parser = AfdParser.new(true)
    assert_nil parser.last_creation_date

    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser.parse_line(line, index)
    end
    file.close

    assert_equal Date.civil(2011,2,21), parser.last_creation_date
 end

  def test_equal
    parser1 = AfdParser.new(true)
    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser1.parse_line(line, index)
    end
    file.close

    parser2 = AfdParser.new(true)
    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser2.parse_line(line, index)
    end
    file.close
    assert_equal parser2, parser1

    different_data = ["0000000001100000000067890000000009876RAZAO_SOCIAL                                                                                                                                          000040000700044032001201122022011210220111048",
                      "0000000014280120111112280120111113",
                      "0000000022270120111756108682040000172000000000000O.S. SYSTEMS SOFTWARES LTDA.                                                                                                                          PELOTAS - RS                                                                                        ",
                      "0000000035270120111759I111111111111TESTE 1 2 3                                         ",
                      "0000000045110220111723E222222222222TESTE 2                                             ",
                      "0000000053210220111134111111111111",
                      "9999999990000000010000000010000000010000000029"]

    parser2 = AfdParser.new(true)
    different_data.each_with_index do |line, index|
      parser2.parse_line(line, index)
    end
    assert_not_equal parser2, parser1
  end

  def test_get_last_id
    parser = AfdParser.new(true)
    assert_nil parser.first_id
    assert_nil parser.last_id

    parser = AfdParser.new(true)
    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser.parse_line(line, index)
    end
    file.close
    assert_equal 1, parser.first_id
    assert_equal 9, parser.last_id

    different_data = [["0000000001100000000067890000000009876NOVISSIMA EMPRESA SA.                                                                                                                                 000040000700044032001201105082011050820111711",0],
                      ["0000000102270120111756108682040000172000000000000NOVISSIMA EMPRESA SA.                                                                                                                                 PELOTAS - RS                                                                                        ",10],
                      ["0000000113210220111134111111111111",11]]

    parser = AfdParser.new(true)
    different_data.each do |line, index|
      parser.parse_line(line, index)
    end

    assert_equal 10, parser.first_id
    assert_equal 11, parser.last_id

    different_data = [["0000000001100000000067890000000009876NOVISSIMA EMPRESA SA.                                                                                                                                 000040000700044032001201105082011050820111711",0],
                      ["0000000102270120111756108682040000172000000000000NOVISSIMA EMPRESA SA.                                                                                                                                 PELOTAS - RS                                                                                        ",10]]

    parser = AfdParser.new(true)
    different_data.each do |line, index|
      parser.parse_line(line, index)
    end

    assert_equal 10, parser.last_id
    assert_equal 10, parser.last_id
  end

  def test_merge
    parser1 = AfdParser.new(true)
    file = File.open("test/afd_file", "r")
    file.readlines.each_with_index do |line, index|
      parser1.parse_line(line, index)
    end

    different_data = [["0000000001100000000067890000000009876NOVISSIMA EMPRESA SA.                                                                                                                                 000040000700044032001201105082011050820111711",0],
                      ["0000000102270120111756108682040000172000000000000NOVISSIMA EMPRESA SA.                                                                                                                                 PELOTAS - RS                                                                                        ",10],
                      ["0000000113050820111134111111111111",11]]

    parser2 = AfdParser.new(true)
    exception = assert_raise AfdParser::AfdParserException do
      parser1.merge parser2
    end
    assert_equal "Cannot merge with a empty parser", exception.message

    different_data.each do |line, index|
      parser2.parse_line(line, index)
    end
    parser1.merge parser2

    parsed_records = parser1.records
    assert_equal 11, parsed_records.size

    assert_equal 0, parser1.header.line_id
    assert_equal 1, parser1.header.record_type_id
    assert_equal :cnpj, parser1.header.employer_type
    assert_equal Time.local(2011,8,5,17,11), parser1.header.afd_creation_time
    assert_equal Date.civil(2011,1,20), parser1.header.afd_start_date
    assert_equal Date.civil(2011,8,5), parser1.header.afd_end_date
    assert_equal "00004000070004403", parser1.header.rep_serial_number
    assert_equal "NOVISSIMA EMPRESA SA.", parser1.header.employer_name
    assert_equal 67890, parser1.header.employer_document
    assert_equal 9876, parser1.header.employer_cei

    set_time = parsed_records[0]
    assert_equal 1, set_time.line_id
    assert_equal Time.local(2011,1,28,11,13), set_time.after_time
    assert_equal Time.local(2011,1,28,11,12), set_time.before_time
    assert_equal 4, set_time.record_type_id

    set_employer = parsed_records[1]
    assert_equal 8682040000172, set_employer.document_number
    assert_equal 2, set_employer.line_id
    assert_equal "PELOTAS - RS", set_employer.location
    assert_equal :cnpj, set_employer.document_type
    assert_equal Time.local(2011,1,27,17,56), set_employer.creation_time
    assert_equal 0, set_employer.cei
    assert_equal "O.S. SYSTEMS SOFTWARES LTDA.", set_employer.name
    assert_equal 2, set_employer.record_type_id

    set_employee = parsed_records[2]
    assert_equal 111111111111, set_employee.pis
    assert_equal 3, set_employee.line_id
    assert_equal :add, set_employee.operation_type
    assert_equal Time.local(2011,1,27,17,59), set_employee.creation_time
    assert_equal "TESTE 1 2 3", set_employee.name
    assert_equal 5, set_employee.record_type_id

    set_employee = parsed_records[3]
    assert_equal 222222222222, set_employee.pis
    assert_equal 4, set_employee.line_id
    assert_equal :add, set_employee.operation_type
    assert_equal Time.local(2011,2,8,17,9), set_employee.creation_time
    assert_equal "TESTE 2", set_employee.name
    assert_equal 5, set_employee.record_type_id

    set_employee = parsed_records[4]
    assert_equal 222222222222, set_employee.pis
    assert_equal 5, set_employee.line_id
    assert_equal :edit, set_employee.operation_type
    assert_equal Time.local(2011,2,11,17,19), set_employee.creation_time
    assert_equal "TESTE 2", set_employee.name
    assert_equal 5, set_employee.record_type_id

    set_employee = parsed_records[5]
    assert_equal 222222222222, set_employee.pis
    assert_equal 6, set_employee.line_id
    assert_equal :remove, set_employee.operation_type
    assert_equal Time.local(2011,2,11,17,23), set_employee.creation_time
    assert_equal "TESTE 2", set_employee.name
    assert_equal 5, set_employee.record_type_id

    clock_in_out = parsed_records[6]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 7, clock_in_out.line_id
    assert_equal Time.local(2011,2,19,18,14), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    clock_in_out = parsed_records[7]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 8, clock_in_out.line_id
    assert_equal Time.local(2011,2,21,11,33), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    clock_in_out = parsed_records[8]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 9, clock_in_out.line_id
    assert_equal Time.local(2011,2,21,11,34), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    set_employer = parsed_records[9]
    assert_equal 8682040000172, set_employer.document_number
    assert_equal 10, set_employer.line_id
    assert_equal "PELOTAS - RS", set_employer.location
    assert_equal :cnpj, set_employer.document_type
    assert_equal Time.local(2011,1,27,17,56), set_employer.creation_time
    assert_equal 0, set_employer.cei
    assert_equal "NOVISSIMA EMPRESA SA.", set_employer.name
    assert_equal 2, set_employer.record_type_id

    clock_in_out = parsed_records[10]
    assert_equal 111111111111, clock_in_out.pis
    assert_equal 11, clock_in_out.line_id
    assert_equal Time.local(2011,8,5,11,34), clock_in_out.creation_time
    assert_equal 3, clock_in_out.record_type_id

    assert_equal 3, parser1.trailer.clock_in_out
    assert_equal 999999999, parser1.trailer.line_id
    assert_equal 1, parser1.trailer.set_employer
    assert_equal 4, parser1.trailer.set_employee
    assert_equal 1, parser1.trailer.set_time
    assert_equal 9, parser1.trailer.record_type_id
  end

  def test_load_ignoring_invalid_utf_8_data
    parser = AfdParser.new(true)
    file = File.open("test/afd_invalid_utf-8_chars", "r")
    file.readlines.each_with_index do |line, index|
      parser.parse_line(line, index)
    end

    parsed_records = parser.records
    assert_equal 1, parsed_records.size

    assert_equal 0, parser.header.line_id
    assert_equal 1, parser.header.record_type_id
    assert_equal :cnpj, parser.header.employer_type
    assert_equal Time.local(2011,8,5,17,11), parser.header.afd_creation_time
    assert_equal Date.civil(2011,1,20), parser.header.afd_start_date
    assert_equal Date.civil(2011,8,5), parser.header.afd_end_date
    assert_equal "00004000070004403", parser.header.rep_serial_number
    assert_equal "NOVISSIMA EMPRESA SA.", parser.header.employer_name
    assert_equal 67890, parser.header.employer_document
    assert_equal 9876, parser.header.employer_cei

    set_employer = parsed_records[0]
    assert_equal 11111111111111, set_employer.document_number
    assert_equal 1, set_employer.line_id
    assert_equal "INVALID COMPANY ERRORsgf&\001", set_employer.name
    assert_equal "COMPANY LOCATION WITH ERROR                                                          sgf&\001", set_employer.location
    assert_equal :cnpj, set_employer.document_type
    assert_equal Time.local(2011,1,24,16,59), set_employer.creation_time
    assert_equal 0, set_employer.cei
    assert_equal 2, set_employer.record_type_id

    assert_nil parser.trailer
  end

  private
  def create_temp_afd_file(data)
    file = Tempfile.new('afd_error')
    file.write data
    file.close
    file.path
  end
end
