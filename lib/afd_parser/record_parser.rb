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

class AfdParser::RecordParser
  def self.size
    raise "record size not defined for parser class '#{self.class.to_s}'"
  end

  def export
    raise "record export is not defined for parser class '#{self.class.to_s}'"
  end

  private
  def parse_date(date_array)
    day   = date_array[0..1].to_i
    month = date_array[2..3].to_i
    year  = date_array[4..7].to_i
    Date.civil(year,month,day)
  end

  def parse_time(date_array)
    day    = date_array[0..1].to_i
    month  = date_array[2..3].to_i
    year   = date_array[4..7].to_i
    hour   = date_array[8..9].to_i
    minute = date_array[10..11].to_i
    Time.local(year,month,day,hour,minute)
  end

  def format_date(date)
    date.class == Date ? date.strftime("%d%m%Y") : date.to_s
  end

  def format_time(time)
    time.class == Time ? time.strftime("%d%m%Y%H%M") : time.to_s
  end

  def well_formed_number_string?(string)
    string.to_i.to_s.rjust(string.size, "0") == string
  end

  # Destructively removes invalid utf-8 chars from strings. Ignores data from
  # other classes.
  def _clean!(string)
    return string unless string.class == String
    string.force_encoding('ISO-8859-1').encode('UTF-8', {:invalid => :replace, :replace => ""})
  end
end
