# Modules, Include, Prepend, POLYMORPHISM

*  Modules are made up of methods and variables, but they can't be instantiated
*  They are used to add functionality to a class


### Allows you access to the Human module (Ruby 2+)

**`human.rb`**

```
module Human
	attr_accessor :name, :height, :weight
	#  Creates setter and getter methods

	def run
		puts self.name + " runs"
		#  self provides this specific objects value for a variable
	end
end
```

**`smart.rb`**

```
module Smart
	def act_smart
		return "E = mc2"
	end
end
```

### You can inherit a modules methods with prepend or include
### You can inherit from numerous methods instead of one class


```
class Dog
  include Animal
end
 
rover = Dog.new
rover.make_sound

> Grrr
> Albert
 
class Scientist
  include Human
  prepend Smart # Any methods in Smart will supersede those in the class
 
  def act_smart
    return "E = mc^2"
  end
 
end
 
einstein = Scientist.new
 
einstein.name = "Albert"
 
puts einstein.name
 
einstein.run
 
puts einstein.name + " says " + einstein.act_smart


> Albert runs
> Albert says E = mc2
```

## POLYMORPHISM


```
class Bird
	def tweet(bird_type)
		bird_type.tweet
	end
end

class Cardinal < Bird
	def tweet
		puts "Tweet tweet"
	end
end

class Parrot < Bird
	def tweet
		puts "Squawk"
	end
end

generic_bird = Bird.new()
generic_bird.tweet(Cardinal.new)
generic_bird.tweet(Parrot.new)

# Statically typed languages use duck typing to achieve polymorphism
# Ruby pays less attention to the class type versus the methods that can
# be called on it

>>> Tweet tweet
>>> Squawk
```






