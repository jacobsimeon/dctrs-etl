require_relative "config"
require_relative "helpers"

# Automated tasks to import the NPI Data Dissemination file into Elasticsearch
# Example usage:
#
# Download and transform taxonomies (required for adding provider specialties)
# `rake taxonomies:extract taxonomies:transform`
#
# Download and prepare the Data Dissemination file for transformation
# `rake extract:download extract:unzip extract:clean extract:all`
#
# Transform the CSV data into Elasticsearch bulk import files
# `rake transform:build_files transform:transform`
#
# Run the bulk import
# `rake load:clean load:load`

desc "Run complete ETL operation (long download times)"
task :etl => ["taxonomies", "extract", "transform", "load"]

desc "Run all extraction operations in order"
task :extract => ["extract:download", "extract:unzip", "extract:clean", "extract:all"]
namespace :extract do
  desc "Remove and re-create the data directory."
  task :clean do
    system "rm -rf #{DATA_ROOT}"
    system "mkdir #{DATA_ROOT}"
  end

  desc "Download the NPI Data Dissemination bundle and place in temp directory"
  task :download do
    system "rm -rf #{TMP_ROOT}"
    system "mkdir #{TMP_ROOT}"

    system "curl #{find_monthly_url} > #{ZIP_SOURCE}"
  end

  desc "Unzip the NPI Data Dissemination bundle via 7zip"
  task :unzip do
    system "7za -o#{TMP_ROOT} x #{ZIP_SOURCE}"
  end

  desc "Clean up file names and place accompanying documentation in doc directory"
  task :sanitize do
    csv_files = Dir["#{TMP_ROOT}/*.csv"]
    header_file = csv_files.find { |f| f[/Header/] }
    main_file = csv_files.find { |f| !f[/Header/] }

    pdfs = Dir["#{TMP_ROOT}/*.pdf"]
    readme = pdfs.find { |f| f[/Readme/] }
    readme_dest = File.join(DOC_ROOT, "readme.pdf")
    system "mv \"#{readme}\" \"#{readme_dest}\""

    code_values = pdfs.find { |f| f[/codevalues/i] }
    code_values_dest = File.join(DOC_ROOT, "code_values.pdf")
    system "mv \"#{code_values}\" \"#{code_values_dest}\""

    system "mv #{header_file} #{HEADER_SOURCE}"
    system "mv #{main_file} #{CSV_SOURCE}"
  end

  desc "Extract a sample of the Data Dissemination file (for development/testing)."
  task sample: :clean do
    system "head -n #{SAMPLE_SIZE} #{CSV_SOURCE} > #{CSV_DESTINATION}"
    system "cp #{HEADER_SOURCE} #{HEADER_DESTINATION}"
  end

  desc "Move the Data Dissemination file to the data directory (for use in 'transform' step)"
  task all: :clean do
    system "cp #{CSV_SOURCE} #{CSV_DESTINATION}"
    system "cp #{HEADER_SOURCE} #{HEADER_DESTINATION}"
  end

end

desc "Run all transform steps in order"
task :transform => "transform:transform"
namespace :transform do
  desc "Clean the output of the last transformation and build an empty directory"
  task :clean do
    system "rm -rf #{OUT_DIR}"
    system "mkdir #{OUT_DIR}"
  end

  desc "Break apart the CSV file into multiple files to be transformed in parallel"
  task :build_files do
    puts "Splitting #{CSV_DESTINATION} into #{PROCESSES} files"
    system "rm -rf #{FILE_CHUNK_DEST}"
    system "mkdir #{FILE_CHUNK_DEST}"

    system "split -a 2 -l #{FILE_CHUNK_SIZE} #{CSV_DESTINATION} #{FILE_CHUNK_PREFIX}"
  end

  desc "Transform the target csv files"
  task transform: [:build_files, :clean] do
    Dir[File.join(FILE_CHUNK_DEST, "*")].each do |input_file_name|
      bare_name = File.basename(input_file_name)
      output_file_name = File.join(OUT_DIR, "#{bare_name}.json")

      puts "Transforming #{input_file_name} to #{output_file_name}"
      Process.spawn "#{TRANSFORM_COMMAND} < #{input_file_name} > #{output_file_name}"
    end

    puts "Transform processes started, waiting for them to finish."
    Process.waitall
  end

end

desc "Run all load operations in order"
task :load => ["load:clean", "load:load"]
namespace :load do
  desc "Bulk import the transformed data into Elasticsearch"
  task :load do
    system "rm -rf #{LOG_ROOT}"
    system "mkdir -p #{LOG_ROOT}"

    Dir[File.join(OUT_DIR, "*")].each do |import_file_name|
      bulk_url = File.join(ES_URL, "_bulk")
      log_path = File.join(LOG_ROOT, "#{File.basename(import_file_name)}.log")

      cmd_gzip = "gzip < #{import_file_name} | curl -s -XPOST --header \"Content-Encoding: gzip\" #{bulk_url} --upload-file - | tee #{log_path} | jq .took"
      cmd_no_gzip = "curl -v -s -XPOST #{bulk_url} --upload-file - < #{import_file_name}"

      if GZIP_REQUEST_BODY
        puts "Loading #{File.basename(import_file_name)} (gzip'd)"
        # puts cmd_gzip
        took = `#{cmd_gzip}`
        puts "Took #{took}"
        puts "Logged to #{log_path}"
      else
        puts "Loading #{File.basename(import_file_name)} (NOT gzip'd)"
        # puts cmd_no_gzip
        system cmd_no_gzip
      end

    end
  end

  desc "Remove the providers index and re-create it"
  task :clean do
    index_url = File.join(ES_URL, ES_INDEX_NAME)
    system "curl -XDELETE #{index_url}"
    system "curl -XPOST #{index_url}"
  end

  desc "Count the number of documents in the providers index"
  task :count do
    count_url = File.join(ES_URL, ES_INDEX_NAME, "_count")
    system "curl -XGET #{count_url}"
  end
end

desc "Download and prepare taxonomies"
task "taxonomies" => ["taxonomies:extract", "taxonomies:transform"]
namespace :taxonomies do
  desc "Download taxonomies from the web"
  task :extract do
    url = File.join(TAXONOMY_ROOT, find_taxonomy_url)
    system "curl #{url} > #{TAX_SOURCE}"

    string = File.read(TAX_SOURCE).encode(
      'UTF-8',
      'binary',
      invalid: :replace,
      undef: :replace,
      replace: ''
    )

    File.open(TAX_SOURCE, "w+") { |f| f << string }
  end

  desc "Transform CSV taxonomies into JSON"
  task :transform do
    require 'csv'
    require 'json'

    specialties = CSV.table(TAX_SOURCE).inject({}) do |taxonomies, row|
      taxonomies[row[:code]] = row.to_hash
      taxonomies
    end

    specialties = JSON.pretty_generate(specialties)
    File.open(TAX_DESTINATION, 'w+') { |f| f << specialties }
  end

end
