import sys
import requests
import os 
import math

print(sys.version)
print(sys.executable)

def greet(who_to_greet):
    greeting = f"Hello, {who_to_greet}"
    return greeting


print(greet("World"))
print(greet("Jacob"))

r = requests.get("https://github.com/Chao-Xi/")
print(r.status_code)

