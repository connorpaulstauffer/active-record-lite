require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      result = DBConnection.execute(<<-SQL, self.id)
        SELECT
          source.*
        FROM
          #{self.class.table_name} self
        JOIN
          #{through_options.table_name} through
        ON
          through.id = self.#{through_options.foreign_key}
        JOIN
          #{source_options.table_name} source
        ON
          source.id = through.#{source_options.foreign_key}
        WHERE
          self.id = ?
      SQL

      source_options.model_class.parse_all(result).first
    end
  end
end
