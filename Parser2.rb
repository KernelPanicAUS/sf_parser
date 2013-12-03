#!/usr/bin/env ruby
# encoding: UTF-8

require 'date'
require 'FileUtils'
require 'Benchmark'

log = File.open("./summary.log","w")
rowcount = 0
filecount = 0
rangehash = {Date.parse("2013-01-01")=>Date.parse("2013-03-31"), Date.parse("2013-04-01")=>Date.parse("2013-06-30"), Date.parse("2013-07-01")=>Date.parse("2013-09-30"), Date.parse("2013-10-01")=>Date.parse("2013-12-31")}
counters = Array.new

# Each lines from the CSV will be fed to the script for evaluation and will be subsequently dumped from memory as the CSV files are quite large.
# Each line will be delimited, the 4 th element which is the record creation date, will be evaluated against a few timeframes which are stored in the rangehash hash.
# If a date does occur, the counter will increment and store the value in the counter array, used to output the stats at the end of the scipt.

time = Benchmark.realtime do
  $stdin.each do |line|
    rangehash.each_with_index do |(start_date, finish_date), index|
      new_range = (start_date..finish_date)

      t = line.split('","').map(&:chomp)
      dirty_date = Date.parse(t[4]) rescue nil
        if new_range.include?(dirty_date)
          rowcount+=1
          counters[index] = rowcount
        end

    end
  filecount+=1
  end
end
# Cycles through the counter array to output the script's outcome.
counters.each_with_index do |counter, index|
  log.write("Range N: #{index+1}, has: #{counter} lines between #{rangehash.flatten[index*2]} and #{rangehash.flatten[(index*2)+1]}\n")
end

log.write("Time elapsed to process this file #{time*1000} seconds\n")
log.write("#{filecount} lines in this file]\n")
log.close