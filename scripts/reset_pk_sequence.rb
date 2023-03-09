# frozen_string_literal: true

ActiveRecord::Base.connection.tables.each do |table|
  puts "Resetting #{table} sequence"
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
end