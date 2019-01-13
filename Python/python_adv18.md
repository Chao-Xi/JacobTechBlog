# Slice list and String

## 1.Slice List

### `list[start:end:step]`

```
my_list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

print(my_list[5])
print(my_list[0:6])          #end is exclusive, start is inclusive
print(my_list[1:-2])

# 5
# [0, 1, 2, 3, 4, 5]
# [1, 2, 3, 4, 5, 6, 7]

print(my_list)
print(my_list[:])         # list all list

# [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
# [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

print(my_list[::-1])
print(my_list[-2::-1])

# [2, 4, 6, 8]
# [8, 6, 4, 2]

print(my_list[::-1])
print(my_list[-2::-1])

# [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
# [8, 7, 6, 5, 4, 3, 2, 1, 0]

```


## 2.Slice String

```
sample_url = 'https://www.youtube.com'
print(sample_url)
# https://www.youtube.com

#Reverse the url
print(sample_url[::-1])
# moc.ebutuoy.www//:sptth    reverse url

# # Get the top level domain
print(sample_url[-4:])
# .com

# # Print the url without the http://
print(sample_url[8:])
# www.youtube.com

# # Print the url without the http:// , com or the top level domain
print(sample_url[12:-4])
# youtube
```
