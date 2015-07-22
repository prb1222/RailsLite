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
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    name_sym = "#{name}_id".to_sym
    class_string = "#{name.to_s.camelcase}"
    self.primary_key = options[:primary_key] || :id
    self.foreign_key = options[:foreign_key] || name_sym
    self.class_name = options[:class_name] || class_string
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    name_sym = "#{self_class_name.downcase}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.foreign_key = options[:foreign_key] || name_sym
    self.class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key_value = send(options.foreign_key)
      primary_key = options.primary_key
      options.model_class.where(primary_key => foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      foreign_key = options.foreign_key
      primary_key_value = send(options.primary_key)
      options.model_class.where(foreign_key => primary_key_value)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
