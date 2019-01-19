# Hiding Passwords and Secret Keys in Environment Variables

Hard-coding secret information is a common mistake that beginners make when learning Python. Hiding this information within environment variables allows you to access your secret information within your code without anyone else being able to see these values from your source code. 

```
import os

db_user = os.environ.get('USER')
db_password = os.environ.get('SECURITYSESSIONID')

print(db_user)
print(db_password)

>>> jxi
>>> None
```

