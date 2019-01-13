# Namedtuple - When and why should you use namedtuples?

**`namedtuple` instances are just as memory efficient as regular tuples because they do not have per-instance dictionaries.**

Each kind of `namedtuple` is represented by its own class, created by using the `namedtuple()` factory function. The arguments are the name of the new class and a string containing the names of the elements.

```
from collections import namedtuple

color = (55, 155, 255)  #tuple

color_dict = {'red':55, 'green': 155, 'blue': 255}  #dictionary


print(color_dict['red']) 
>>> 55

Colors = namedtuple('colors', ['red', 'green', 'blue'])
colors = Colors(55, 155, 255)


print(colors[0])
>>> 55

print(colors.red)
>>> 55

print(colors.blue)
>>> 255

white = Colors(222222, 2222, 22)

print(white.red)
>>>> 22222

print(white.blue)
>>>> 22
```






