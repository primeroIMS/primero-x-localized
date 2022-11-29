#! /usr/bin/env ruby

puts 'Starting Atachments Restore'

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
