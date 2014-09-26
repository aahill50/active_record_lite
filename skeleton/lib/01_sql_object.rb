require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    get_cols_sql = <<-SQL
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    LIMIT
      0
    SQL

    @columns ||= DBConnection
      .execute2(get_cols_sql)
      .flatten.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|
      define_method("#{col}") do
        self.attributes[col]
      end

      define_method("#{col}=") do |value|
        self.attributes[col] = value
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
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
        WHERE
        #{table_name}.id = ?
      LIMIT
        1
    SQL
    self.new(result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr = attr_name.to_sym

      unless self.class.columns.include?(attr)
        raise "unknown attribute '#{attr_name}'"
      end

      self.attributes[attr] = value
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
