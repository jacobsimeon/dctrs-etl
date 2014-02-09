CSV_DOWNLOAD_PAGE_URL = "http://nppes.viva-it.com/NPI_Files.html"

TMP_ROOT = File.expand_path("../tmp", __FILE__)
DATA_ROOT = File.expand_path("../data", __FILE__)

ZIP_FILE_NAME = 'npi_data.zip'
CSV_FILE_NAME = 'npi_data.csv'
HEADER_FILE_NAME = 'npi_data_header.csv'

ZIP_SOURCE = File.join TMP_ROOT, ZIP_FILE_NAME
CSV_SOURCE = File.join TMP_ROOT, CSV_FILE_NAME
HEADER_SOURCE = File.join TMP_ROOT, HEADER_FILE_NAME

CSV_DESTINATION = File.join DATA_ROOT, CSV_FILE_NAME
HEADER_DESTINATION = File.join DATA_ROOT, HEADER_FILE_NAME

SAMPLE_SIZE = 100000

def find_monthly_url
  require 'nokogiri'
  require 'open-uri'

  doc = Nokogiri::HTML(open(CSV_DOWNLOAD_PAGE_URL))
  link = doc.css("a").find do |link|
    link.text[/\ANPPES Data Dissemination \(.*\)\Z/]
  end

  link.attributes['href'].value
end

namespace :extract do
  task :clean do
    system "rm -rf #{DATA_ROOT}"
    system "mkdir #{DATA_ROOT}"
  end

  task :download do
    system "mkdir -p #{TMP_ROOT}"
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
    system "cp #{CSV_SOOURCE} #{CSV_DESTINATION}"
    system "cp #{HEADER_SOURCE} #{HEADER_DESTINATION}"
  end
end
