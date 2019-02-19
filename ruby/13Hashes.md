# Hashes

## A hash is a collection of key object pairs

```
number_hash = { "PI" => 3.14,
                "Golden" => 1.618,
                "e" => 2.718}

puts number_hash["PI"]

> 3.14
```

```
superheroes = Hash["Clark Kent", "Superman", "Bruce Wayne", "Batman"]
 
puts superheroes["Bruce Wayne"]
puts superheroes["Clark Kent"]

> Batman
> Superman
```

## Add to a hash

```
superheroes["Barry Allen"] = "Flash"
puts superheroes["Barry Allen"]
```

## Set a default key value

```
samp_hash = Hash.new("No Such Key")
puts samp_hash["Dog"]
```

### Update, destructive way, delete duplicate
### Merge, undestructive way, keep duplicate

```
superheroines = Hash["Lisa Morel", "Aquagirl", "Betty Kane", "Batgirl"]
superheroes.update(superheroines)

superheroes.each do |key ,value|
	puts key.to_s + " : " + value
end

> Clark Kent : Superman
> Bruce Wayne : Batman
> Barry Allen : Flash
> Lisa Morel : Aquagirl
> Betty Kane : Batgirl
```

```
puts "Has key?: " + superheroes.has_key?("Lisa Morel").to_s
puts "Has value? : " + superheroes.has_value?("Batman").to_s
puts "Is hash empty : " + superheroes.empty?.to_s
puts "Size of Hash: " + superheroes.size.to_s

> Has key?: true
> Has value? : true
> Is hash empty : false
> Size of Hash: 5
```

### Delete

```
superheroes.delete("Barry Allen")
puts "Size of Hash: " + superheroes.size.to_s

> Size of Hash: 4
```






