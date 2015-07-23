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

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      first_table = self.class.table_name
      second_table = through_options.class_name.constantize.table_name
      third_table = source_options.class_name.constantize.table_name
      foreign_key1 = through_options.foreign_key
      primary_key1 = through_options.primary_key
      foreign_key2 = source_options.foreign_key
      primary_key2 = source_options.primary_key
      row = DBConnection.execute(<<-SQL, id)
        SELECT
          #{third_table}.*
        FROM
          #{first_table}
        JOIN
          #{second_table} ON #{first_table}.#{foreign_key1} = #{second_table}.#{primary_key1}
        JOIN
          #{third_table} ON #{second_table}.#{foreign_key2} = #{third_table}.#{primary_key2}
        WHERE
          #{first_table}.id = ?
      SQL
      byebug
      source_options.class_name.constantize.new(self.class.row_parser(row).first)
    end
  end
end
