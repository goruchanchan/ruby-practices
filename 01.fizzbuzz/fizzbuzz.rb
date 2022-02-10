#!/Users/ryo/.rbenv/shims/ruby
# frozen_string_literal: true

20.times do |count|
  if (count % 15).zero?
    puts 'FizzBuzz'
  elsif (count % 5).zero?
    puts 'Buzz'
  elsif (count % 3).zero?
    puts 'Fizz'
  else
    puts count
  end
end
