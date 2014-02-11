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

SAMPLE_SIZE = 100_000

PROCESSES = 12
DATA_FILE_LENGTH = `wc -l #{CSV_DESTINATION}`.split[0].to_i

FILE_CHUNK_SIZE = begin
                    if DATA_FILE_LENGTH % PROCESSES == 0
                      DATA_FILE_LENGTH / PROCESSES
                    else
                      DATA_FILE_LENGTH / (PROCESSES - 1)
                    end
                  end

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

namespace :transform do
  task :test do
    powers = [1, 2, 4, 8, 16, 32, 64, 128, 256]

    powers.each do |processes|
      powers.each do |threads|
        # clean
        system "rm -rf output"
        system "mkdir output"

        system "rm -rf tmp/npi_data"
        system "mkdir tmp/npi_data"

        # build files
        file_chunk_size = if DATA_FILE_LENGTH % processes == 0
                            DATA_FILE_LENGTH / processes
                          else
                            DATA_FILE_LENGTH / (processes - 1)
                          end

        system "split -a 1 -l #{file_chunk_size} #{CSV_DESTINATION} tmp/npi_data/npi_data_"

        # run test
        puts "Processes: #{processes}, Threads: #{threads}"

        10.times do |test_number|
          STDOUT << "Test ##{test_number}: "
          system "THREAD_COUNT=#{threads} time bundle exec rake transform:transform"
        end
      end
    end
  end

  task :clean do
    `rm -rf output`
    `mkdir output`
  end

  task :build_files do
    system "rm -rf tmp/npi_data"
    system "mkdir tmp/npi_data"
    system "split -a 1 -l #{FILE_CHUNK_SIZE} #{CSV_DESTINATION} tmp/npi_data/npi_data_"
  end

  task :transform do
    require "./transform.rb"

    Dir["./tmp/npi_data/*"].map do |file_name|
      bare_name = file_name.split("/").last
      input_file_name = file_name
      output_file_name = "output/#{bare_name}.json"

      fork do
        transformer = TransformDctr.new(input_file_name, output_file_name)
        transformer.transform
      end
    end

    Process.waitall
  end
end
