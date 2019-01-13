# Web Scraping with BeautifulSoup and Requests module

### prerequisite

```
$ pip3 install beautifulsoup4
$ sudo pip3 install requests
```

#### `19_sample.html`

```
<!doctype html>
<html class="no-js" lang="">
    <head>
        <title>Test - A Sample Website</title>
        <meta charset="utf-8">
        <link rel="stylesheet" href="css/normalize.css">
        <link rel="stylesheet" href="css/main.css">
    </head>
    <body>
        <h1 id='site_title'>Test Website</h1>
        <hr></hr>
        <div class="article">
            <h2><a href="article_1.html">Article 1 Headline</a></h2>
            <p>This is a summary of article 1</p>
        </div>
        <hr></hr>
        <div class="article">
            <h2><a href="article_2.html">Article 2 Headline</a></h2>
            <p>This is a summary of article 2</p>
        </div>
        <hr></hr>

        <div class='footer'>
            <p>Footer Information</p>
        </div>

        <script src="js/vendor/modernizr-3.5.0.min.js"></script>
        <script src="js/plugins.js"></script>
        <script src="js/main.js"></script>
    </body>
</html> 
```


## Scrap the simple html page

```
from bs4 import BeautifulSoup
import requests

# output with correct indent

with open('19_sample.html') as html_file:
	soup = BeautifulSoup(html_file, 'lxml')

print(soup.prettify())

>>> 
<!DOCTYPE html>
<html class="no-js" lang="">
 <head>
  <title>
   Test - A Sample Website
  </title>
  <meta charset="utf-8"/>
  <link href="css/normalize.css" rel="stylesheet"/>
  <link href="css/main.css" rel="stylesheet"/>
 </head>
 <body>
  <h1 id="site_title">
   Test Website
  </h1>
  <hr/>
  <div class="article">
   <h2>
    <a href="article_1.html">
     Article 1 Headline
    </a>
   </h2>
   <p>
    This is a summary of article 1
   </p>
  </div>
  <hr/>
  <div class="article">
   <h2>
    <a href="article_2.html">
     Article 2 Headline
    </a>
   </h2>
   <p>
    This is a summary of article 2
   </p>
  </div>
  <hr/>
  <div class="footer">
   <p>
    Footer Information
   </p>
  </div>
  <script src="js/vendor/modernizr-3.5.0.min.js">
  </script>
  <script src="js/plugins.js">
  </script>
  <script src="js/main.js">
  </script>
 </body>
</html>
```

### output specific part of this page

**1.html title**

```
match = soup.title.text
print(match)

>>> Test - A Sample Website
```

**2.div section**

```
match1 = soup.div
print(match1)

<div class="article">
<h2><a href="article_1.html">Article 1 Headline</a></h2>
<p>This is a summary of article 1</p>
</div>
```
**3.div section with specific class use `find` function**

Use `class_` because class is key in python

```
match2 = soup.find('div', class_='footer')  #class_ because class is key word in python
print(match2)

<div class="footer">
<p>Footer Information</p>
</div>
```

**4.`find` element inside div section with specific class**

```
article = soup.find('div', class_='article') #class_ because class is key word in python
headline = article.h2.a.text
print(headline)
>>> Article 1 Headline

summary = article.p.text
print(summary)
>>> This is a summary of article 1
```

**5.`find_all` function find all specific element inside html page**

```
for article in soup.find_all('div', class_='article'):

	headline = article.h2.a.text
	print(headline)

	summary = article.p.text
	print(summary)

	print()

>>>Article 1 Headline
>>>This is a summary of article 1

>>>Article 2 Headline
>>>This is a summary of article 2
```

## Scrap the real and complicate page


#### 1.find 'iframe' section with specific class

```
from bs4 import BeautifulSoup
import requests
import csv

source = requests.get("http://coreyms.com").text

soup = BeautifulSoup(source, 'lxml')

article = soup.find('article')

vid_sec = article.find('iframe', class_='youtube-player')
print(vid_sec)

>>> <iframe allowfullscreen="true" class="youtube-player" height="360" src="https://www.youtube.com/embed/goToXTC96Co?version=3&amp;rel=1&amp;fs=1&amp;autohide=2&amp;showsearch=0&amp;showinfo=1&amp;iv_load_policy=1&amp;wmode=transparent" style="border:0;" type="text/html" width="640"></iframe>
```

#### 2.find 'iframe' section with specific class and get src from it

```
vid_src = article.find('iframe', class_='youtube-player')['src']
print(vid_src)

>>> https://www.youtube.com/embed/goToXTC96Co?version=3&rel=1&fs=1&autohide=2&showsearch=0&showinfo=1&iv_load_policy=1&wmode=transparent
```

#### 3.find 'iframe' section with specific class and get src and slice it

```
vid_id = vid_src.split('/')
print(vid_id)

>>> ['https:', '', 'www.youtube.com', 'embed', 'goToXTC96Co?version=3&rel=1&fs=1&autohide=2&showsearch=0&showinfo=1&iv_load_policy=1&wmode=transparent']


vid_id_4 = vid_src.split('/')[4]
print(vid_id_4)

>>> goToXTC96Co?version=3&rel=1&fs=1&autohide=2&showsearch=0&showinfo=1&iv_load_policy=1&wmode=transparent

vid_id_4_0 = vid_id_4.split('?')[0]
print(vid_id_4_0)
>>> goToXTC96Co


yt_link = f'https://youtube.com/watch?v={vid_id_4_0}'
print(yt_link)
>>> https://youtube.com/watch?v=goToXTC96Co
```

### Save scraped part into csv

```
for article in soup.find_all('article'):
	
	headline = article.h2.a.text
	print(headline)

	summary = article.find('div', class_='entry-content').p.text
	print(summary)
    
   # some articles may dont have youtube link
	try:
		vid_src = article.find('iframe', class_='youtube-player')['src']
		vid_id_4 = vid_src.split('/')[4]
		vid_id_4_0 = vid_id_4.split('?')[0]
		yt_link = f'https://youtube.com/watch?v={vid_id_4_0}'
	except Exception as e:
		yt_link = None

	print(yt_link)

	print()

	csv_writer.writerow([headline, summary, yt_link])

csv_file.close()

```












