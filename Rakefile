CSV_DOWNLOAD_PAGE_URL = "http://nppes.viva-it.com/NPI_Files.html"
require 'nokogiri'
require 'open-uri'
require 'pp'

def find_monthly_url
  doc = Nokogiri::HTML(open(CSV_DOWNLOAD_PAGE_URL))
  link = doc.css("a").find do |link|
    link.text[/\ANPPES Data Dissemination \(.*\)\Z/]
  end

  link.attributes['href'].value
end

namespace :data do
  task :clean do
    `rm -rf data`
  end

  task :download do
    `mkdir data`
    `curl #{find_monthly_url} > data/npi_data.zip`
  end

  task :unzip do
    `7za -o./data x data/npi_data.zip`
  end

  task :sanitize do
    `rm data/*.pdf`
    `rm -rf data/complete`
    `mkdir data/complete`

    csv_files = Dir['data/*.csv']
    header_file = csv_files.find { |f| f[/Header/] }
    main_file = csv_files.find { |f| !f[/Header/] }

    `mv #{header_file} data/complete/npi_data_header.csv`
    `mv #{main_file} data/complete/npi_data.csv`
  end

  task :sample do
    `rm -rf data/sample`
    `mkdir data/sample`
    `head -n 100000 data/complete/npi_data.csv > data/sample/npi_data.csv`
    `cp data/complete/npi_data_header.csv data/sample/npi_data_header.csv`
  end

  task rebuild: %i(clean download unzip sanitize sample)
end
