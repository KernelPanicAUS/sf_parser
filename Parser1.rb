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
in_scope = File.open("./in_scope.log","w")
rowcount = 0
filecount = 0
rangehash = {Date.parse("2012-01-01")=>Date.parse("2012-03-31"), Date.parse("2012-04-01")=>Date.parse("2012-06-30"), Date.parse("2012-07-01")=>Date.parse("2012-09-30"), Date.parse("2012-10-01")=>Date.parse("2012-12-31"),
             Date.parse("2013-01-01")=>Date.parse("2013-03-31"), Date.parse("2013-04-01")=>Date.parse("2013-06-30"), Date.parse("2013-07-01")=>Date.parse("2013-09-30"), Date.parse("2013-10-01")=>Date.parse("2013-12-31")}
counters = ["0","0","0","0","0","0","0","0"]

# Each lines from the CSV will be fed to the script for evaluation and will be subsequently dumped from memory as the CSV files are quite large.
# Each line will be delimited, the 4 th element which is the record creation date, will be evaluated against a few timeframes which are stored in the rangehash hash.
# If a date does occur, the counter will increment and store the value in the counter array, used to output the stats at the end of the scipt.

log.write("#{Time.now}\n")

time = Benchmark.realtime do
  CSV.with_progress_bar.foreach("/Users/Thomas/GitHub/SiteMinder/scripts/sf_parser/EmailMessage_utf8.csv",:headers => true) do |row|
    rangehash.each_with_index do |(start_date, finish_date), index|
      new_range = (start_date..finish_date)
      dirty_date = Date.parse(row[4].split[0]) rescue nil
      # in_scope.write("#{dirty_date.to_s},  #{start_date.to_s},  #{finish_date.to_s},  Index : #{index},  ")
        if new_range.include?(dirty_date)
          # rowcount+=1
          counters[index] += 1
          # in_scope.write("Yes,  counter : #{index},  value : #{counters[index]}\n")
        else
          # in_scope.write("No,  counter : #{index},  value : #{counters[index]}\n")
        end

    # in_scope.write("#{counters}")
    end
  filecount+=1
  end
end

# Cycles through the counter array to output the script's outcome.
counters.each_with_index do |counter, index|
  log.write("Range N: #{index+1}, has: #{counter} lines between #{rangehash.flatten[index*2]} and #{rangehash.flatten[(index*2)+1]}\n")
end

log.write("Time elapsed to process this file #{time/60} seconds""\n")
log.write("#{filecount} lines in this file""\n\n\n")
log.close
in_scope.close
puts "#{time/60}"