require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    conditions = params.map { |attr_name, _| "#{attr_name} = ?" }.join(' AND ')
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{conditions}
    SQL
    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
