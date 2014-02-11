require 'csv'
require 'json'
require 'thread/pool'

class TransformDctr
  THREAD_COUNT = ENV["THREAD_COUNT"].to_i

  def initialize(input_file_name, output_file_name)
    @input_file_name, @output_file_name = input_file_name, output_file_name
  end

  def transform
    input_file.each_line do |line|
      pool.process { process_line(line) }
    end

    close
  end

  private
  def pool
    @pool ||= Thread.pool(THREAD_COUNT)
  end

  def output_file
    @output_file ||= File.open(@output_file_name, 'a')
  end

  def input_file
    @input_file ||= File.open(@input_file_name, 'r')
  end

  def process_line(line)
    dctr = Dctr.new(line)
    output_file << "#{dctr.meta}\n#{dctr.json}\n"
  end

  def close
    pool.shutdown

    input_file.close
    @input_file = nil

    output_file.close
    @output_file = nil
  end
end

class Dctr
  attr_accessor :csv

  def self.meta
    @meta ||= { action: :update }.to_json
  end

  def initialize(line)
    CSV.parse(line) do |row|
      @csv = row
    end
  end

  def meta
    self.class.meta
  end

  def json
    @json ||= { npi: @csv[0] }.to_json
  end
end
