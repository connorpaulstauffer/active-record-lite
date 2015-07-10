require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    "#{class_name.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ||
                     "#{self_class_name.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.capitalize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options_hash = {})
    options = BelongsToOptions.new(name, options_hash)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = options.foreign_key
      primary_key = options.primary_key
      other_table_name = options.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          o.*
        FROM
          #{self.class.table_name} s
        JOIN
          #{other_table_name} o ON o.#{primary_key} = s.#{foreign_key}
        WHERE
          s.id = ?
      SQL

      options.model_class.parse_all(results).first
    end
  end

  def has_many(name, options_hash = {})
    options = HasManyOptions.new(name, self.name, options_hash)

    define_method(name) do
      foreign_key = options.foreign_key
      primary_key = options.primary_key
      other_table_name = options.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          o.*
        FROM
          #{self.class.table_name} s
        JOIN
          #{other_table_name} o ON s.#{primary_key} = o.#{foreign_key}
        WHERE
          s.id = ?
      SQL

      options.model_class.parse_all(results)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
