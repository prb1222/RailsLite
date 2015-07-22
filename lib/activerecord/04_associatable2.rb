require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
