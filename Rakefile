CSV_DOWNLOAD_PAGE_URL = "http://nppes.viva-it.com/NPI_Files.html"

ROOT                  = File.expand_path("../", __FILE__)

TMP_ROOT              = File.join(ROOT, "tmp")
DATA_ROOT             = File.join(ROOT, "data")
OUT_DIR               = File.join(ROOT, "out")

ZIP_FILE_NAME         = 'npi_data.zip'
CSV_FILE_NAME         = 'npi_data.csv'
HEADER_FILE_NAME      = 'npi_data_header.csv'

ZIP_SOURCE            = File.join TMP_ROOT, ZIP_FILE_NAME
CSV_SOURCE            = File.join TMP_ROOT, CSV_FILE_NAME
HEADER_SOURCE         = File.join TMP_ROOT, HEADER_FILE_NAME

CSV_DESTINATION       = File.join DATA_ROOT, CSV_FILE_NAME
HEADER_DESTINATION    = File.join DATA_ROOT, HEADER_FILE_NAME

SAMPLE_SIZE           = 50_000

DATA_FILE_LENGTH      = `wc -l #{CSV_DESTINATION}`.split[0].to_i

PROCESSES             = 8
FILE_CHUNK_DEST       = File.join(TMP_ROOT, "npi_data")
FILE_CHUNK_PREFIX     = File.join(FILE_CHUNK_DEST, "npi_data_")

FILE_CHUNK_SIZE       = if DATA_FILE_LENGTH % PROCESSES == 0
                          DATA_FILE_LENGTH / PROCESSES
                        else
                          DATA_FILE_LENGTH / (PROCESSES - 1)
                        end

TRANSFORM_COMMAND     = "./bin/transform"

ES_URL                = "https://p85r5xdj:rdpoxxikk9s0357e@oak-7316449.us-east-1.bonsai.io/"
# ES_URL              = "http://localhost:9200"
ES_INDEX_NAME         = "dctrs"


def find_monthly_url
  require 'nokogiri'
  require 'open-uri'

  doc = Nokogiri::HTML(open(CSV_DOWNLOAD_PAGE_URL))
  link = doc.css("a").find do |_link|
    _link.text[/\ANPPES Data Dissemination \(.*\)\Z/]
  end

  link.attributes['href'].value
end


namespace :extract do

  task :clean do
    system "rm -rf #{DATA_ROOT}"
    system "mkdir #{DATA_ROOT}"
  end

  task :download do
    system "rm -rf #{TMP_ROOT}"
    system "mkdir #{TMP_ROOT}"

    system "curl #{find_monthly_url} > #{ZIP_SOURCE}"
  end

  task :unzip do
    system "7za -o#{TMP_ROOT} x #{ZIP_SOURCE}"
  end

  task :sanitize do
    system "rm #{TMP_ROOT}/*.pdf"

    csv_files = Dir["#{TMP_ROOT}/*.csv"]
    header_file = csv_files.find { |f| f[/Header/] }
    main_file = csv_files.find { |f| !f[/Header/] }

    system "mv #{header_file} #{HEADER_SOURCE}"
    system "mv #{main_file} #{CSV_SOURCE}"
  end

  task sample: :clean do
    system "head -n #{SAMPLE_SIZE} #{CSV_SOURCE} > #{CSV_DESTINATION}"
    system "cp #{HEADER_SOURCE} #{HEADER_DESTINATION}"
  end

  task all: :clean do
    system "cp #{CSV_SOURCE} #{CSV_DESTINATION}"
    system "cp #{HEADER_SOURCE} #{HEADER_DESTINATION}"
  end

end

namespace :transform do

  task :clean do
    system "rm -rf #{OUT_DIR}"
    system "mkdir #{OUT_DIR}"
  end

  task :build_files do
    system "rm -rf #{FILE_CHUNK_DEST}"
    system "mkdir #{FILE_CHUNK_DEST}"

    system "split -a 2 -l #{FILE_CHUNK_SIZE} #{CSV_DESTINATION} #{FILE_CHUNK_PREFIX}"
  end

  task :transform do
    Dir[File.join(FILE_CHUNK_DEST, "*")].each do |input_file_name|
      bare_name = File.barename(input_file_name)
      output_file_name = File.join(OUT_DIR, "#{bare_name}.json")

      puts "Transforming #{input_file_name} to #{output_file_name}"
      Process.spawn "#{TRANSFORM_COMMAND} < #{input_file_name} > #{output_file_name}"
    end

    puts "Transform processes started, waiting for them to finish."
    Process.waitall
  end

end

namespace :load do

  task :load do
    system "mkdir -p #{LOG_ROOT}"

    Dir[File.join(OUT_DIR, "*")].each do |import_file_name|
      bare_name = File.barename(input_file_name)

      puts "Importing #{import_file_name}"
      cmd = "curl -s -XPOST #{ES_URL}/_bulk --upload-file - < #{import_file_name} > log/#{bare_name}.log.json"
      system cmd
    end
  end

  task :clean do
    system "curl -XDELETE #{ES_URL}/#{INDEX_NAME}"
    system "curl -XPOST #{ES_URL}/#{INDEX_NAME}"
  end

  task :count do
    system "curl -XGET #{ES_URL}/#{INDEX_NAME}/_count"
  end

end
