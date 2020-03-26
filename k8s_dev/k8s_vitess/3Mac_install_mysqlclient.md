# Mac 安装 mysqlclient

##Step One: install MySQL

Using **Homebrew** you can install **mysql** simply by:

```
brew install mysql
```

Then setup the credentials in MySQL server using the following command:

```
mysql_secure_installation
```

Then setup the credentials in MySQL server using the following command:

```
$ brew install mysql
...
We've installed your MySQL database without a root password. To secure it run:
    mysql_secure_installation

MySQL is configured to only allow connections from localhost by default

To connect run:
    mysql -uroot

To have launchd start mysql now and restart at login:
  brew services start mysql
Or, if you don't want/need a background service you can just run:
  mysql.server start
```

You want to start at login and as a background service, run this:

```
brew services start mysql
```

Else

```
mysql.server start
```

> Optional

Then setup the credentials in MySQL server using the following command:

```
mysql_secure_installation
```


## Step two: install `MySQL-Connector-C` 

For connecting any other application to MySQL, you need to install a connector. You can do it like this:

```
brew install mysql-connector-c
```

Then according to [mysqlclient’s](https://pypi.org/project/mysqlclient/) documentation, you need to put a bugfix at mysql_config. For that first type mysql_config in terminal.:

```
$ mysql_config
Usage: /usr/local/bin/mysql_config [OPTIONS]
Compiler: AppleClang 11.0.0.11000033
...
```

It will show where you need to find `mysql_config`. Then you can use any of the editor of your liking and change the following lines inside the `mysql_config`:

**Change:**

```
# on macOS, on or about line 112:
# Create options
libs="-L$pkglibdir"
libs="$libs -l "
```

**To**

```
# Create options
libs="-L$pkglibdir"
libs="$libs -lmysqlclient -lssl -lcrypto"
```

## Step three:unlink MySQL and link `MySQL-Connector-C` 

You need to **unlink** mysql and link **mysql-connector-c**:

```
$ brew unlink mysql
Unlinking /usr/local/Cellar/mysql/8.0.19... 88 symlinks removed


$ brew link --overwrite mysql-connector-c
Warning: mysql-client is keg-only and must be linked with --force

If you need to have this software first in your PATH instead consider running:
  echo 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"' >> ~/.bash_profile
```

```
echo 'export PATH="/usr/local/opt/mysql-client/bin:$PATH"' >> ~/.bash_profile

source ~/.bash_profile

$ which mysql_config
/usr/local/opt/mysql-client/bin/mysql_config
```


## Step four: install mysqlclient

```
pip3 install mysqlclient
```

```
$ pip3 install mysqlclient
Collecting mysqlclient
  Using cached https://files.pythonhosted.org/packages/d0/97/7326248ac8d5049968bf4ec708a5d3d4806e412a42e74160d7f266a3e03a/mysqlclient-1.
4.6.tar.gz
Building wheels for collected packages: mysqlclient
  Building wheel for mysqlclient (setup.py) ... done
  Created wheel for mysqlclient: filename=mysqlclient-1.4.6-cp37-cp37m-macosx_10_15_x86_64.whl size=55823 sha256=c6e3d4130b46504c8d25a64b892aa721192bb2b717ae8a1236a356a06a3da1d8
  Stored in directory: /Users/i515190/Library/Caches/pip/wheels/37/3d/24/5327fa50817a65ed0ee4dc8809e5c39962b0dd5e078ebf4dc1
Successfully built mysqlclient
Installing collected packages: mysqlclient
Successfully installed mysqlclient-1.4.6
```

## Step five: link MySQL back again ︎

```
brew unlink mysql-connector-c
brew link --overwrite mysql
```

