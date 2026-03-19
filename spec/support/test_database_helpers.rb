module TestDatabaseHelpers
  module_function

  IGNORED_TABLES = %w[schema_migrations ar_internal_metadata].freeze

  def clean
    connection = ActiveRecord::Base.connection

    connection.disable_referential_integrity do
      (connection.tables - IGNORED_TABLES).each do |table|
        connection.execute("DELETE FROM #{connection.quote_table_name(table)}")
      end
    end
  end
end
