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

require 'date'

require 'afd_parser/clock_in_out'
require 'afd_parser/header'
require 'afd_parser/set_employee'
require 'afd_parser/set_employer'
require 'afd_parser/set_time'
require 'afd_parser/trailer'

# Parser para a PORTARIA No 1.510, DE 21 DE AGOSTO DE 2009, do
# Ministério do Trabalho;

class AfdParser
  class AfdParserException < Exception; end
  attr_reader :records, :header, :trailer

  def initialize(*args)
    if args.size == 1
      initialize_variables(args[0])
    elsif args.size == 2
      initialize_variables(args[1])
      File.open(args[0], "r") do |file|
        @raw_data = file.readlines
      end
    else
      raise AfdParserException.new("wrong number of arguments, should be 1 or 2")
    end
  end

  def parse
    @raw_data.each_with_index do |line, index|
      parse_line(line, index)
    end

    if @validate_structure and not trailer_found?
      raise AfdParserException.new("AFD ended without a trailer record")
    end
  end

  def parse_line(line, index)
    line_id, record_type_id = line.unpack("A9A").collect{|id| id.to_i}
    record_type = get_record_type(line_id, record_type_id, line)

    if @validate_structure
      validate_afd(line, line_id, index, record_type)
    end

    case record_type
    when :header
      @header = Header.new(line)
      return @header
    when :set_employer
      @records << SetEmployer.new(line)
    when :clock_in_out
      @records << ClockInOut.new(line)
    when :set_time
      @records << SetTime.new(line)
    when :set_employee
      @records << SetEmployee.new(line)
    when :trailer
      @trailer = Trailer.new(line, count_records)
      return @trailer
    else
      if @validate_structure
        raise AfdParserException.new("Unknown record type found in AFD file, line #{index.to_s}: '#{line}'")
      end
    end

    return @records.last
  end

  def create_header(employer_type, employer_document, employer_cei, employer_name, rep_serial_number, afd_start_date,afd_end_date, afd_creation_time)
    if header_found?
      raise AfdParserException.new("Cannot add a second AFD header")
    else
      @header = Header.new(employer_type, employer_document, employer_cei, employer_name, rep_serial_number, afd_start_date,afd_end_date, afd_creation_time)
    end
  end

  def create_trailer
    if trailer_found?
      raise AfdParserException.new("Cannot add a second AFD trailer")
    else
      @trailer = Trailer.new(count_records)
    end
  end

  def export
    exported_data = ""
    (exported_data += @header.export + "\r\n") if @header
    @records.each do |record|
      exported_data += record.export + "\r\n"
    end
    (exported_data += @trailer.export + "\r\n") if @trailer

    exported_data
  end

  def first_creation_date
    record = @records[0]
    if record
      time = record.creation_time
      return Date.civil(time.year, time.month, time.day)
    end
  end

  def last_creation_date
    record = @records[-1]
    if record
      time = record.creation_time
      return Date.civil(time.year, time.month, time.day)
    end
  end

  def ==(other)
    return self.class == other.class && @records == other.records
  end

  # get the first id after the AFD header
  def first_id
    first_record = @records[0]
    first_record ? first_record.line_id : nil
  end

  # get the last id before the AFD trailer
  def last_id
    last_record = @records[-1]
    last_record ? last_record.line_id : nil
  end

  def merge(other)
    other_first_id, other_last_id = other.first_id, other.last_id
    if other_first_id.nil? || other_last_id.nil?
      raise AfdParserException.new("Cannot merge with a empty parser")
    end

    @header = other.header if other.header

    # merge is done by grouping all the records by line id, and replacing
    # the ones in "self" by duplicates of the ones in "other".
    this_records_by_line_id = @records.group_by{|record| record.line_id}
    other_records_by_line_id = other.records.group_by{|record| record.line_id}
    other_records_by_line_id.keys.each do |key|
      this_records_by_line_id[key] = other_records_by_line_id[key].dup
    end
    @records = this_records_by_line_id.keys.sort.collect{|key| this_records_by_line_id[key]}.flatten

    @trailer = nil
    create_trailer
  end

  private
  def initialize_variables(validate_structure)
    @records = []
    @validate_structure = validate_structure
  end

  def get_record_type(line_id, record_type_id, line)
    if record_type_id == 1
      return :header
    elsif line_id == 999999999 and line.unpack("x45A").first.to_i == 9
      return :trailer
    elsif line_id != 0
      case record_type_id
      when 2
        return :set_employer
      when 3
        return :clock_in_out
      when 4
        return :set_time
      when 5
        return :set_employee
      end
    end

    return nil
  end

  def validate_afd(line, line_id, index, record_type)
    raise AfdParserException.new("Line #{index.to_s} is blank") if line.nil? || line.empty?

    if line_id != index and not (line_id == 999999999 and not trailer_found?)
      raise AfdParserException.new("Out-of-order line id on line 1; expected '#{index.to_s}', got '#{line_id.to_s}'")
    end

    if trailer_found?
      raise AfdParserException.new("Unexpected AFD record found after trailer, line #{index.to_s}: '#{line}'")
    end

    if not header_found? and record_type != :header
      raise AfdParserException.new("Unexpected AFD record found before header, line #{index.to_s}: '#{line}'")
    end

    if header_found? and record_type == :header
      raise AfdParserException.new("Unexpected second AFD header found, line #{index.to_s}: '#{line}'")
    end
  end

  def header_found?
    !@header.nil?
  end

  def trailer_found?
    !@trailer.nil?
  end

  def count_records
    counter = {:set_employer => 0, :clock_in_out => 0, :set_time => 0, :set_employee => 0}
    @records.each do |record|
      case record
      when *SetEmployer
        counter[:set_employer] += 1
      when *ClockInOut
        counter[:clock_in_out] += 1
      when *SetTime
        counter[:set_time] += 1
      when *SetEmployee
        counter[:set_employee] += 1
      end
    end
    return counter
  end
end
