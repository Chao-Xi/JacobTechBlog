# Request Web Pages, Download Images, POST Data, Read JSON

## Request Web Pages

```
import requests

r = requests.get("https://xkcd.com/353")

print(r)

# <Response [200]>

print(dir(r))

# ['__attrs__', '__bool__', '__class__', '__delattr__', '__dict__', '__dir__', '__doc__', '__enter__', '__eq__', '__exit__', '__format__', '__ge__', '__getattribute__', '__getstate__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__iter__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__nonzero__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__setstate__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_content', '_content_consumed', '_next', 'apparent_encoding', 'close', 'connection', 'content', 'cookies', 'elapsed', 'encoding', 'headers', 'history', 'is_permanent_redirect', 'is_redirect', 'iter_content', 'iter_lines', 'json', 'links', 'next', 'ok', 'raise_for_status', 'raw', 'reason', 'request', 'status_code', 'text', 'url']
```

### Get help of request

```
print(help(r))
```

### Get web content

```
print(r.text)

# <!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="/s/b0dcca.css" title="Default"/>
<title>xkcd: Python</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<link rel="shortcut icon" href="/s/919f27.ico" type="image/x-icon"/>
<link rel="icon" href="/s/919f27.ico" type="image/x-icon"/>
...
<a href="http://creativecommons.org/licenses/by-nc/2.5/">Creative Commons Attribution-NonCommercial 2.5 License</a>.
</p><p>
This means you're free to copy and share these comics (but not to sell them). <a rel="license" href="/license.html">More details</a>.</p>
</div>
</div>
</body>
<!-- Layout by Ian Clasbey, davean, and chromakode -->
</html>
```

## Deal with images

```
img = requests.get("https://imgs.xkcd.com/comics/python.png")
# print(img.content)   # print image binary content
```

### download image

```
with open('34comics.png', "wb") as f:
	f.write(img.content)
```

### check image exist?

```
print(img.status_code)
# 200

print(img.ok)
# True
```

### image headers

```
print(img.headers)

# {'Server': 'nginx', 'Content-Type': 'image/png', 'Last-Modified': 'Mon, 01 Feb 2010 13:07:49 GMT', 'ETag': '"4b66d225-162d3"', 'Expires': 'Wed, 27 Feb 2019 07:25:38 GMT', 'Cache-Control': 'max-age=300', 'Content-Length': '90835', 'Accept-Ranges': 'bytes', 'Date': 'Wed, 27 Feb 2019 07:47:18 GMT', 'Via': '1.1 varnish', 'Age': '83', 'Connection': 'keep-alive', 'X-Served-By': 'cache-bwi5049-BWI', 'X-Cache': 'HIT', 'X-Cache-Hits': '1', 'X-Timer': 'S1551253638.438373,VS0,VE1'}
```

## Request get with `params`

```
payload = {'page':2, 'count':25}
load = requests.get('https://httpbin.org/get', params=payload)

print(r.url)

# https://xkcd.com/353/
```

## Request post with `data` and Read JSON

```
newpayload = {'usrename':'jxi', 'password':'test'}
newload = requests.post('https://httpbin.org/post', data=newpayload)

newload_dict=newload.json()

print(newload_dict["form"])

# {'password': 'test', 'usrename': 'jxi'}
```

## Authentication with Request

```
auth = requests.get('https://httpbin.org/basic-auth/jxi/test', auth=('jxi','test'))
print(auth.text)

# {
  "authenticated": true, 
  "user": "jxi"
}

print(auth)

# <Response [200]>
```

## Timeout

```
timeout= requests.get('https://httpbin.org/delay/1', timeout=3)
print(timeout)

# <Response [200]>
```

```
newtimeout= requests.get('https://httpbin.org/delay/6', timeout=3)
print(newtimeout)

# socket.timeout: The read operation timed out
# During handling of the above exception, another exception occurred:
```





