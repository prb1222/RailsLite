require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    value_arr = params.values
    where_arr = params.keys.map{|key| "#{key} = ?"}
    options_array = where_arr.zip(value_arr)
    Relation.new(self, options_array)
  end

end

class SQLObject
  extend Searchable
end

class Relation
  attr_accessor :class_name, :options

  def initialize(class_name, options)
    @class_name = class_name
    @options = options
  end

  def execute_query
    where_arr, values_arr = unpack_args
    where_string = where_arr.join(" AND ")
    rows = DBConnection.execute(<<-SQL, *values_arr)
      SELECT
        *
      FROM
        #{self.class_name.table_name}
      WHERE
        #{where_string}
    SQL
    return rows if rows.empty?
    rows = class_name.row_parser(rows)
    rows.map{|row| class_name.new(row)}
  end

  def where(params)
    value_arr = params.values
    where_arr = params.keys.map{|key| "#{key} = ?"}
    options_array = where_arr.zip(value_arr)
    @options.concat(options_array)
  end

  def unpack_args
    where_arr = @options.map(&:first)
    values_arr = @options.map(&:last)
    [where_arr, values_arr]
  end

  def method_missing(m, *args, &block)
    if [].respond_to?(m)
      execute_query.send(m, *args, &block)
    else
      raise "Undefined method #{m} for Relation"
    end
  end
end
