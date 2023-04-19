#! /usr/bin/env ruby

puts 'Wiping out Attachmnets tables'

ActiveRecord::Base.connection.execute('DELETE FROM active_storage_variant_records')
ActiveRecord::Base.connection.execute('DELETE FROM active_storage_attachments')
ActiveRecord::Base.connection.execute('DELETE FROM attachments')
ActiveRecord::Base.connection.execute('DELETE FROM active_storage_blobs')

puts 'Starting Attachments Restore'

Dir['/tmp/backup-attachments/*.rb'].each do |file_path|
  puts '-----------------------------------------------'
  puts "Loading file #{file_path}"
  puts '-----------------------------------------------'
  begin
    require_relative(file_path)
  rescue SyntaxError => e
    puts "could not be exported #{file_path} due to #{e}"
  end
end
