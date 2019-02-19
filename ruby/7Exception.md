# EXCEPTIONS

## We catch exceptions with begin and rescue

```
print "Enter a number : "
 
first_num = gets.to_i
 
print "Enter Another : "
 
second_num = gets.to_i
 
begin
  answer = first_num / second_num
 
rescue # You could use rescue ZeroDivisionError
  puts "You can't divide by zero"
  exit
end
 
puts "#{first_num} / #{second_num} = #{answer}"

```


## You can throw your own exceptions with raise

```
def check_age(age)
  raise ArgumentError, "Enter Positive Number" unless age > 0
end

begin
	check_age(-2)
rescue ArgumentError
	puts "That is an impossible age"
end 

>>> That is an impossible age
```


