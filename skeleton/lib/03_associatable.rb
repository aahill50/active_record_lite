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
    self.class_name.to_s.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    defaults = {class_name: name.to_s.camelcase,
                foreign_key: (name.to_s + "_id").to_sym,
                primary_key: :id
               }

    options = defaults.merge(options)
    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name = name.singularize.camelcase,
                 options = {})
    defaults = {class_name: name.singularize.camelcase,
                foreign_key: (self_class_name.underscore + "_id").to_sym,
                primary_key: :id
               }

    options = defaults.merge(options)
    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    cls = options.send(:model_class)
    p fk = self.send(:foreign_key)
    pk = options.send(:primary_key).to_s
    their_tbl = cls.table_name
    my_tbl = self.table_name

    results = DBConnection.execute(<<-SQL)
      SELECT
        #{their_tbl}.*
      FROM
        #{their_tbl}
      WHERE
        #{their_tbl}.#{pk} = 1
    SQL

    results.map { |result| cls.new(result) }
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
