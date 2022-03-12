#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'date'

params = ARGV.getopts('m:y:')

params['m'] = Date.today.month unless params['m']
params['y'] = Date.today.year unless params['y']

puts "      #{params['m']}月 #{params['y']}"
puts '日 月 火 水 木 金 土'

last_day_of_month = Date.new(params['y'].to_i, params['m'].to_i, -1).day
date = Date.new(params['y'].to_i, params['m'].to_i, 1)

print '   ' * date.wday

last_day_of_month.times do
  day = date.day.to_s.rjust(2)
  print(date == Date.today ? "\e[7m#{day}\e[0m" : day)
  print ' '

  puts if date.saturday?
  date = date.next_day
end

puts
puts
