# frozen_string_literal: true

ActiveRecord::Base.connection.tables.each do |table|
  quoted_table_name = ActiveRecord::Base.connection.quote_table_name(table)
  count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{quoted_table_name}")
  puts "table= #{table}, count= #{count}"
end

puts "Total records with status open, record_state true and created_at from 01/01/2020 and Today"
puts Child.search { with(:status, 'open'); with(:record_state, true); with(:created_at, DateTime.new(2020, 01, 01).beginning_of_day..DateTime.now.end_of_day) }.total


puts "Total records with status open, record_state false and created_at from 01/01/2020 and Today"
puts Child.search { with(:status, 'open'); with(:record_state, false); with(:created_at, DateTime.new(2020, 01, 01).beginning_of_day..DateTime.now.end_of_day) }.total
