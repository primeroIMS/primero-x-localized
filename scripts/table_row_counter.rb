# frozen_string_literal: true

ActiveRecord::Base.connection.tables.each do |table|
  quoted_table_name = ActiveRecord::Base.connection.quote_table_name(table)
  count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{quoted_table_name}")
  puts "table= #{table}, count= #{count}"
end
