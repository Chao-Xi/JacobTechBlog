# Image Manipulation with Pillow

How to modify and manipulate images using the Python Pillow Library. Pillow is a fork of the Python Imaging Library (PIL). It will allow us to do many different things to our images such as: changing their file extension, resizing, cropping, changing colors, blurring, and much more.


## Prequisite

```
$ pip3 install Pillow
```


## Open and Save Image

### Open image

```
from PIL import Image

image1 = Image.open('../images/headline.jpg')
image1.show()
```

### Save image

```
image1.save('../images/headline.png')
```


## Modify Image

### Modify multiple images extension

```
import os
for f in os.listdir('../images/.'):
	print(f)
	if f.endswith('.jpg') or f.endswith('.jpeg'):
		i = Image.open(f'../images/{f}')
		fn, fext = os.path.splitext(f)
		i.save('28png/{}.png'.format(fn))
```

### Resizing multiple images `thumbnail(new_size)`

```
import os

size_300 = (300, 300)
size_700 = (700, 700)

for f in os.listdir('../images/.'):
	print(f)
	if f.endswith('.jpg') or f.endswith('.jpeg'):
		i = Image.open(f'../images/{f}')
		fn, fext = os.path.splitext(f)


		i.thumbnail(size_300)
		i.save(f'28s300/{fn}_300.png')

		i.thumbnail(size_700)
		i.save(f'28s700/{fn}_700.png')
```

### Rotating multiple images `rotate(rotate_degree)`

```
import os

rotate_degree = 90

for f in os.listdir('../images/.'):
	print(f)
	if f.endswith('.jpg') or f.endswith('.jpeg'):
		i = Image.open(f'../images/{f}')
		fn, fext = os.path.splitext(f)

		i.rotate(rotate_degree).save(f'28r90/{fn}_r90.png')

```

### Changing color of multiple images(black and white) `convert(mode='L')`

```
for f in os.listdir('../images/.'):
	print(f)
	if f.endswith('.jpg') or f.endswith('.jpeg'):
		i = Image.open(f'../images/{f}')
		fn, fext = os.path.splitext(f)

		i.convert(mode='L').save(f'28BW/{fn}_bw.png')
```

### Blurring image `filter(ImageFilter.GaussianBlur(blur_index))`

```
from PIL import ImageFilter

image1 = Image.open('../images/headline.jpg')
image1.filter(ImageFilter.GaussianBlur(10)).save('28BW/headline_blur.png')
```