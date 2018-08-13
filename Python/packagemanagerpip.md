![Alt Image Text](images/headline1.jpg "Headline image")
# Python package manager system (pip)

**pip** is a **package management system** used to install and manage software packages written in Python. Many packages can be found in the default source for packages --  Python Package Index (PyPI).


## The way to install pip

### Option 1

```
sudo apt-get update && sudo apt-get -y upgrade
```
Then

```
sudo apt-get -y install python3-pip
```
```
sudo apt-get install python-pip
```

### Option 2 Install Pip with Curl and Python

```
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
```

```
python get-pip.py
```
```
python3 get-pip.py
```

##  Verify The Installation

**View a list of helpful commands:**

```
pip --help
```
**Check the version of Pip that is installed:**

```
pip -V
```
```
pip3 -V
pip 18.0 from /home/vagrant/.pyenv/versions/3.6.4/lib/python3.6/site-packages/pip (python 3.6)
```
## show pip2 and pip3 packages install location

```
$ pip3 show pip
```

```
$ pip show pip
```

```
Name: pip
Version: 18.0
Summary: The PyPA recommended tool for installing Python packages.
Home-page: https://pip.pypa.io/
Author: The pip developers
Author-email: pypa-dev@groups.google.com
License: MIT
Location: /home/vagrant/.pyenv/versions/3.6.4/lib/python3.6/site-packages
Requires:
Required-by:
```

## Upgrade old version pip

```
pip install --upgrade pip
```


## List installed packages

```
$ pip list
Package    Version
---------- -------
pip        18.0
setuptools 40.0.0
```

## Output installed packages in requirements format

```
$  pip freeze
Pympler==0.5
```

## Check pip packages wanna install

```
$ pip search Pympler
Pympler (0.5)  - A development tool to measure, monitor and analyze the memory behavior of Python objects.
  INSTALLED: 0.5 (latest)
```

```
$ pip install Pympler
```
```
 pip3 list
Package    Version
---------- -------
pip        18.0
Pympler    0.5
setuptools 40.0.0
```


## List old pip packages already installed 

```
$ pip list -o
```

```
$ pip list --outdated
```

```
Package   Version Latest   Type
--------- ------- -------- -----
kitchen   1.1.1   1.2.5    sdist
pycurl    7.19.0  7.43.0.2 sdist
pygobject 3.22.0  3.28.3   sdist
pyxattr   0.5.1   0.6.1    sdist
```

## Update one package 

```
pip install -U setuptools
```

## Output installed package list 

```
pip freeze > requirement.txt
cat requirement.txt
```
```
chardet==3.0.4
configobj==5.0.6
decorator==4.3.0
docutils==0.14
iniparse==0.4
IPy==0.83
kitchen==1.1.1
...
```

### install with the package list

```
pip install -r requirement.txt
```

`-r required packages `

## Update all outdated packages

```
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
``` 

```
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install --user -U
``` 

In older version of `pip`, you can use this instead:

```
pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
```



