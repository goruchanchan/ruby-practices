#!/Users/ryo/.rbenv/shims/ruby
# frozen_string_literal: true

require 'optparse'
require 'date'
require 'paint'

params = ARGV.getopts('m:y:')

params['m'] = Date.today.month unless params['m']
params['y'] = Date.today.year unless params['y']

puts "      #{params['m']}月 #{params['y']}"
puts '日 月 火 水 木 金 土'

# newを毎回しちゃうとメモリを食うので、eachの前で変数に格納
last_day_of_month = Date.new(params['y'].to_i, params['m'].to_i, -1).day
date = Date.new(params['y'].to_i, params['m'].to_i, 1)

last_day_of_month.times do
  date.wday.times { print '   ' } if date.day == 1

  if date == Date.today
    print Paint[date.day.to_s.rjust(2), :inverse]
  else
    print date.day.to_s.rjust(2)
  end
  print ' '

  puts if date.saturday?
  date = date.next_day
end

puts
puts
