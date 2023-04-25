#! /usr/bin/env ruby

def write_script_for_attachment(record_type, data, file_name)
  file_path = "#{data.record_type}/#{data.record_id}"
  if %w[Agency BulkExport].include?(record_type)
    return write_script_for_agency_bulks_exports(data, file_name, file_path)
  end

  write_script_for_records(data, file_name, file_path)
end

def write_script_for_records(data, file_name, file_path)
  @output.puts "current_file = File.open(\"\#{File.dirname(__FILE__)}/#{file_path}/#{file_name}\")"
  @output.puts "attachement = Attachment.new(#{data.as_json.except('id')})"
  @output.puts "attachement.file.attach(io: current_file , filename: \"#{file_name}\")"
  @output.puts 'begin'
  @output.puts "  puts \"[#{data.record_type}] - Saving attach #{file_name} in record id: #{data.record_id}.\""
  @output.puts '  attachement.save!'
  @output.puts '  current_file.close'
  @output.puts 'rescue StandardError => e'
  @output.puts "  puts \"Cannot attach #{file_name}. Error \#{e.message}\""
  @output.puts "end\n\n\n"
end

def write_script_for_agency_bulks_exports(data, file_name, file_path)
  @output.puts "file = File.open(\"\#{File.dirname(__FILE__)}/#{file_path}/#{file_name}\")"
  @output.puts "record = #{data.record_type}.find(#{data.record_id})"
  @output.puts "record.#{data.name}.attach(io: file , filename: \"#{file_name}\")"
  @output.puts 'begin'
  @output.puts "  puts \"[#{data.record_type}] - Saving attach #{file_name} fro #{data.name} in record id: #{data.record_id}.\""
  @output.puts '  record.save!'
  @output.puts '  file.close'
  @output.puts 'rescue StandardError => e'
  @output.puts "  puts \"Cannot attach #{file_name}. Error \#{e.message}\""
  @output.puts "end\n\n\n"
end

def export_files
  lock_file_path = "#{Rails.root}/.last_time_attachment_backup_executed.lock"
  last_time_attachment_backup_executed = File.read(lock_file_path)
  puts "====> #{last_time_attachment_backup_executed}"
  condition = last_time_attachment_backup_executed.present? ? { created_at: last_time_attachment_backup_executed.. } : {}
  puts "Export executed last time: #{last_time_attachment_backup_executed}" if last_time_attachment_backup_executed.present?

  blobs = ActiveStorage::Blob.includes(:attachments).where(condition)

  new_time_attachment_backup_executed = Time.now
  backup_path = '/tmp/'

  blobs.find_in_batches(batch_size: 10).with_index(1) do |group, index|
    puts "Processing group ##{index}"

    @output = File.new("#{backup_path}/attachment-#{index}.rb", 'w')
    group.each do |blob|
      blob.attachments.each do |attachment|
        attachment_record = %w[Agency BulkExport].include?(attachment.record_type) ? attachment : attachment.record

        next if attachment_record.nil?

        backup_record_path = "#{backup_path}/#{attachment_record.record_type}/#{attachment_record.record_id}"
        FileUtils.mkdir_p(backup_record_path)
        file_path = "#{backup_record_path}/#{blob.filename}"
        write_script_for_attachment(attachment.record_type, attachment_record, blob.filename.to_s.gsub("'", %q(\\\')).gsub('"', '\"'))
        puts "Saving #{file_path}"
        File.open(file_path, 'wb') do |file|
          file.write(blob.download)
        end
      end
    end
  end

  puts Dir["#{backup_path}/*"]
  File.open(lock_file_path, 'w') do |file|
    file.write(new_time_attachment_backup_executed)
  end
end

export_files
