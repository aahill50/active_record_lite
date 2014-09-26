require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    vals = []

    where_line = params.map do |attr, value|
      vals << value
      "#{attr} = ?"
    end

    where_line = where_line.join(" AND ")

    results = DBConnection.execute(<<-SQL, *vals)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    results.map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
