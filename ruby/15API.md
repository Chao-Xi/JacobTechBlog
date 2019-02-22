# Get and Post work with an API in Ruby

[The Ultimate Guide to HTTP Requests in Ruby](https://www.rubyguides.com/2018/08/ruby-http-request/)

This is a basic API that has posts and makes them available to the API through the json data type, as shown below:

```
http://edutechional-resty.herokuapp.com/posts.json
```

```
[
  {
    "id": 40,
    "title": "Welcome",
    "description": "Bai",
    "url": "http://edutechional-resty.herokuapp.com/posts/40.json"
  },
  {
    "id": 41,
    "title": "test",
    "description": "test",
    "url": "http://edutechional-resty.herokuapp.com/posts/41.json"
  },
  {
    "id": 42,
    "title": "My post",
    "description": "test message",
    "url": "http://edutechional-resty.herokuapp.com/posts/42.json"
  },
  {
    "id": 43,
    "title": "ola",
    "description": "ja",
    "url": "http://edutechional-resty.herokuapp.com/posts/43.json"
  },
  {
    "id": 44,
    "title": "Welcome",
    "description": "Welcome",
    "url": "http://edutechional-resty.herokuapp.com/posts/44.json"
  }
]
```

There are many requirements for interacting with APIs in Ruby, and in this guide we are going to leverage the `httparty` RubyGem to handle API communication. 

If you don’t have this gem on your local system, you can install it with the command 

`gem install httparty`

[How to install required gem for my project](0Required_module.md)

In this file, add the require code to make `httparty` available to this file. The rest of the code looks like this:

```
require 'rubygems'
require 'httparty'

class GetApiInfo
	include HTTParty
	base_uri "http://edutechional-resty.herokuapp.com"

	def posts
		self.class.get('/posts.json')
	end
end
```

In this code, we are creating a class called `GetApiInfo`. We start by including the `httparty` call, and then use a variable that this gem provides called `base_uri`. As the name suggests, this is the base URI we are going to be using for this application.

Next, we create a method called posts and call an instance of this method. It takes a parameter, which is the endpoint of our API’s URL. So, this is all we have to do inside this class.

Now, we have to create an instance of this class and print it out.

```
apiInfo = GetApiInfo.new
puts apiInfo.posts


{"id"=>40, "title"=>"Welcome", "description"=>"Bai", "url"=>"http://edutechional-resty.herokuapp.com/posts/40.json"}
{"id"=>41, "title"=>"test", "description"=>"test", "url"=>"http://edutechional-resty.herokuapp.com/posts/41.json"}
{"id"=>42, "title"=>"My post", "description"=>"test message", "url"=>"http://edutechional-resty.herokuapp.com/posts/42.json"}
{"id"=>43, "title"=>"ola", "description"=>"ja", "url"=>"http://edutechional-resty.herokuapp.com/posts/43.json"}
{"id"=>44, "title"=>"Welcome", "description"=>"Welcome", "url"=>"http://edutechional-resty.herokuapp.com/posts/44.json"}
```

### Parsing an API in Ruby

```
apiInfo.posts.each do |post|
	# puts post
	p "Title: #{post['title']} | Description: #{post['description']} "
end
```

### Get API with authentication (username, password)

```
auth = { username: username, password: password}
resp = HTTParty.get(api_url, basic_auth: auth)
```


### Get HTTP response status and body

```
require 'httparty'
response = HTTParty.get('http://example.com')
response.code
# 200
response.body
# ...
```

### For example


```
auth = { username: username, password: password}

def is_instance_locked(base_url, identifier, fleet, auth)
	 api_url = "#{base_url}/learns/#{identifier}/lockstate.json?fleet=#{fleet}"
	 resp = HTTParty.get(api_url, basic_auth: auth)
     
     if resp.code == 200
     	if resp['state'] == "unlocked"
     		return false
     	elsif resp['state'] == "locked"
     		return true
     	else
     		raise "Unrecognized response #{resp}"
     	end
     else
     	raise "Failed to communicate with Captian statuscode: #{resp.code}" 
     end
end
```

## How to Submit Data With a Post Request


**If you want to submit information use a POST request.**

```
HTTParty.post("http://example.com/login", body: { user: "test@example.com", password: "chunky_bacon" })
```

**To upload a file you’ll need a multipart request**, which is not supported by HTTParty.

You can use the rest client gem:

```
require 'rest-client'
RestClient.post '/profile', file: File.new('photo.jpg', 'rb')
```

Or the Faraday gem:

```
require 'faraday'
conn =
Faraday.new do |f|
  f.request :multipart
  f.request :url_encoded
  f.adapter :net_http
end
file_io = Faraday::UploadIO.new('photo.jpg', 'image/jpeg')
conn.post('http://example.com/profile', file: file_io)
```

### Example

```
def unlock_instance(base_url, identifier, fleet, username, password)
	api_url = "#{base_url}learns/#{identifier}/unlock.json?fleet=#{fleet}"
	auth = { username: username, password: password}
			
	resp = HTTParty.post(api_url, basic_auth: auth)
	if resp.code == 200
		return
	else
		raise "Failed to unlock instance statuscode: #{resp.code} #{resp}"
	end
end
```