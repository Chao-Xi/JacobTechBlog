# File I/O and File handler

## File handler

### Returns a File object for writing

```
writer_handler = File.new("3file.out", "w")
```

### Puts the text in the file

```
write_handler.puts("Random Text").to_s
```

### Closes the file

```
write_handler.close
```

### Read data from the defined file

```
data_from_file = File.read("3file.out")

puts "Data From File : " + data_from_file
```


## Load file

Use load to execute the code in another Ruby file

```
load "2Arithmetic_operator.rb"
```

## File I/O

### The class File provides for file manipulation

### Create a file for writing

```
file = File.new("15filetest.out", "w")
```

### Add lines

```
file.puts "WS"
file.puts "AC"
file.puts "BC"
```

### Close file

```
file.close()
```

### Output everything in the file

```
puts File.read("15filetest.out")
```

### Open file for appending

```
file = File.new("15filetest.out", "a")
file.puts "DS"
file.close
puts File.read("15filetest.out")
```

## Create another file containing data separated by commas

```
file = File.new("author_info.out", "w")
file.puts "William Shakespeare,English,plays and poetry,4 billion"
file.puts "Agatha Christie,English,who done its,4 billion"
file.puts "Barbara Cartland,English,romance novels,1 billion"
file.puts "Danielle Steel,English,romance novels,800 million"
file.close
```

### Cycle through the data to write a sentence

```
File.open("author_info.out") do |record|
  record.each do |item|
 
    # Split each line into 4 parts based on commas
    name, lang, specialty, sales = item.chomp.split(',')
    puts "#{name} was an #{lang} author that specialized in #{specialty}. They sold over #{sales} books."
  end
end
```


