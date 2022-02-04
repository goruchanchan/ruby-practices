#!/Users/ryo/.rbenv/shims/ruby

count = 1

while count < 21
  case
  when count % 15 == 0
    puts "FizzBuzz"
  when count % 5 == 0
    puts "Buzz"
  when count % 3 == 0
    puts "Fizz"
  else
    puts count
  end
  count += 1
end