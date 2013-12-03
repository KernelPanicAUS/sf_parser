#!/usr/bin/env ruby
# encoding: UTF-8

require 'date'
require 'FileUtils'
require 'Benchmark'

log = File.open("./summary.log","w")
not_in_scope = File.open("./not_in_scope.log","w")
in_scope = File.open("./in_scope.log","w")
rowcount = 0
filecount = 0
rangehash = {Date.parse("2013-01-01")=>Date.parse("2013-03-31"), Date.parse("2013-04-01")=>Date.parse("2013-06-30"), Date.parse("2013-07-01")=>Date.parse("2013-09-30"), Date.parse("2013-10-01")=>Date.parse("2013-12-31")}
counters = Array.new

# Each lines from the CSV will be fed to the script for evaluation and will be subsequently dumped from memory as the CSV files are quite large.
# Each line will be delimited, the 4 th element which is the record creation date, will be evaluated against a few timeframes which are stored in the rangehash hash.
# If a date does occur, the counter will increment and store the value in the counter array, used to output the stats at the end of the scipt.

log.write("\n#{Time.now}""\n")

time = Benchmark.realtime do
  $stdin.each do |line|
    rangehash.each_with_index do |(start_date, finish_date), index|
      new_range = (start_date..finish_date)
    
      t = line.split('","').map(&:chomp)
      dirty_date = Date.parse(t[4]) rescue nil
        if new_range.include?(dirty_date)
          in_scope.write("#{dirty_date.to_s},#{start_date.to_s},#{finish_date.to_s}\n")
          rowcount+=1
          counters[index] = rowcount
        end
        not_in_scope.write("#{dirty_date.to_s},#{start_date.to_s},#{finish_date.to_s}\n")
    end
  filecount+=1
  end
end

# Cycles through the counter array to output the script's outcome.
counters.each_with_index do |counter, index|
  log.write("Range N: #{index+1}, has: #{counter} lines between #{rangehash.flatten[index*2]} and #{rangehash.flatten[(index*2)+1]}")
end

log.write("Time elapsed to process this file #{time/60} seconds""\n")
log.write("#{filecount} lines in this file""\n\n\n")
log.close
in_scope.close
not_in_scope.close
