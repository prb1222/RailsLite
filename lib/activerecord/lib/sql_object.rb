require_relative 'db_connection'
require 'active_support/inflector'
require_relative 'searchable'
require_relative 'associatable'
require 'byebug'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    return @columns if @columns
    table = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns = table.first.map(&:to_sym)
  end

  def self.finalize!
    symbols = self.columns
    symbols.each do |symbol|
      define_method("#{symbol}") do
        attributes[symbol]
      end

      define_method("#{symbol}=") do |value|
        attributes[symbol] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    rows = row_parser(rows)
    self.parse_all(rows)
  end

  def self.row_parser(rows)
    parsed_rows = []
    rows.each_with_index do |row, idx|
      parsed_rows[idx] = {}
      row.each{|key, value| parsed_rows[idx][key.to_sym] = value}
    end
    parsed_rows
  end

  def self.parse_all(results)
    objects = []
    results.each do |hash|
      objects << self.new(hash)
    end
    objects
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id.to_i)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    return if row.length == 0
    row = row_parser(row).first
    self.new(row)
  end

  def self.find_by(search_params)
    search_arr = []
    search_params.each do |key, value|
      search_arr << "#{key} = \'#{value}\'"
    end
    search_string = search_arr.join(" AND ")

    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{search_string}
    SQL
    return if rows.length == 0
    row = row_parser(rows).first
    self.new(row)
  end

  def initialize(params = {})
    symbols = self.class.columns
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless symbols.include?(attr_name.to_sym)
      setter_symbol = "#{attr_name}=".to_sym
      send(setter_symbol, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    column_names = self.class.columns.drop(1)
    columns_string = "(" + column_names.join(", ") + ")"
    question_marks = "(" + (["?"]*column_names.length).join(", ") +")"
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} #{columns_string}
      VALUES
        #{question_marks}
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    byebug
    column_names = self.class.columns.drop(1)
    columns_string = column_names.map{|column_name| "#{column_name} = ?"}.join(", ")
    column_values = column_names.map{|column_name| self.send(column_name)}
    DBConnection.execute(<<-SQL, column_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{columns_string}
      WHERE
        id = ?
    SQL
  end

  def save
    if id
      update
    else
      insert
    end
  end
end
