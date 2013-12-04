#!/usr/bin/env ruby
# encoding: UTF-8

require 'date'
require 'FileUtils'
require 'Benchmark'
require 'CSV'
require 'progress_bar'

class CSV
  module ProgressBar
    def progress_bar
      ::ProgressBar.new(@io.size, :bar, :percentage, :elapsed, :eta)
    end

    def each
      progress_bar = self.progress_bar

      super do |row|
        yield row
        progress_bar.count = self.pos
        progress_bar.increment!(0)
      end
    end
  end

  class WithProgressBar < CSV
    include ProgressBar
  end

  def self.with_progress_bar
    WithProgressBar
  end
end

################
# Initialisers #
################
log = File.open("./summary.log","a+")
rowcount = 0
filecount = 0
results = Hash.new(0)
filelist = Array.new

ranges = [(Date.parse("2012-01-01")..Date.parse("2012-03-31")), (Date.parse("2012-04-01")..Date.parse("2012-06-30")), (Date.parse("2012-07-01")..Date.parse("2012-09-30")), (Date.parse("2012-10-01")..Date.parse("2012-12-31")), (Date.parse("2013-01-01")..Date.parse("2013-03-31")), (Date.parse("2013-04-01")..Date.parse("2013-06-30")), (Date.parse("2013-07-01")..Date.parse("2013-09-30")), (Date.parse("2013-10-01")..Date.parse("2013-12-31"))]

# Each lines from the CSV will be fed to the script for evaluation and will be subsequently dumped from memory as the CSV files are quite large.
# Each line will be delimited, the 4 th element which is the record creation date, will be evaluated against a few timeframes which are stored in the rangehash hash.
# If a date does occur, the counter will increment and store the value in the counter array, used to output the stats at the end of the scipt.

log.write("#{Time.now}\n")

# Compiles a list of CSV files in the script's current working directory.
Dir.foreach(".") do |file|
  if File.extname(file) == '.csv'
    filelist << file
  end
end

# Parses every CSV file saved in the previous operation.
filelist.each do |spreadsheet|
  puts spreadsheet
  log.write("Parsing #{spreadsheet} \n")
  
  time = Benchmark.realtime do
    CSV.with_progress_bar.foreach(spreadsheet,:headers => true, encoding:'iso-8859-1:utf-8') do |row|
      
      dirty_date = Date.parse(row[CreatedDate].split[0]) rescue nil
      
      ranges.each do |range|
        results[range] += 1 if range.include? dirty_date
      end

    filecount+=1
    end
    log.write("#{filecount} lines in #{spreadsheet} \n")
    
    results.each do |range, count|
      log.write("#{count} lines found between #{range.first.to_s} and #{range.last.to_s} .\n")
    end
  end
  log.write("Time elapsed to process this file #{time} milliseconds \n\n")
  filecount = 0
end

log.close