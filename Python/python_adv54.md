# Zip Files - Creating and Extracting Zip Archives


## `zipfile` module


### zipfile with traditional way

```
import zipfile

my_zip1 = zipfile.ZipFile('files1.zip', 'w')
my_zip1.write('data.csv')
my_zip1.close()
```


### zipfile with new way without compression

```
# without compression
with zipfile.ZipFile('files1.zip', 'w') as my_zip1:
    my_zip1.write('data.csv')
    my_zip1.write('data7.csv')
```

### zipfile with new way with compression

**`compression=zipfile.ZIP_DEFLATED`**

```
# with compression
with zipfile.ZipFile('files2.zip', 'w', compression=zipfile.ZIP_DEFLATED) as my_zip1:
    my_zip1.write('data.csv')
    my_zip1.write('data7.csv')

```

### Unzip(extract) file from zip file

```
with zipfile.ZipFile('files2.zip', 'r') as my_zip2:
    print(my_zip2.namelist())
    # my_zip2.extractall('data.csv') # only extract data.csv file
    my_zip2.extractall('files2')  # extract all to the files2 folder
```


## `shutil` module

```
import shutil
```

### Pack

```
shutil.make_archive('another', 'zip', 'files2')

# $ ls -a | grep another.zip 
# another.zip
```

### Unpack

```
shutil.unpack_archive('another.zip', 'another')

# $ ls -a | grep another
# another
# another.zip
```

### Pack into gztar(other types)

```
shutil.make_archive('another', 'gztar', 'files2')
#  ls -a | grep another
# another
# another.tar.gz
# another.zip
```

## ZIP from remote resource(web) with `request` module

```
import requests
import zipfile

r = requests.get('https://github.com/CoreyMSchafer/dotfiles/archive/master.zip')

with open('datazip.zip','wb') as f:
    f.write(r.content)

with zipfile.ZipFile('datazip.zip', 'r') as data_zip:
    print(data_zip.namelist())

# Output all name
# ['dotfiles-master/', 'dotfiles-master/.aliases', 'dotfiles-master/.bash_profile', 'dotfiles-master/.bash_prompt', 'dotfiles-master/.bash_server_prompt', 'dotfiles-master/.bashrc', 'dotfiles-master/.gitignore', 'dotfiles-master/LICENSE-MIT.txt', 'dotfiles-master/brew.sh', 'dotfiles-master/install.sh', 'dotfiles-master/settings/', 'dotfiles-master/settings/Anaconda.sublime-settings', 'dotfiles-master/settings/Default (OSX).sublime-keymap', 'dotfiles-master/settings/Material-Theme-Darker.sublime-theme', 'dotfiles-master/settings/Package Control.sublime-package', 'dotfiles-master/settings/Preferences.sublime-settings', 'dotfiles-master/settings/Python-2.sublime-build', 'dotfiles-master/settings/Python-3.sublime-build', 'dotfiles-master/settings/Python-Tut-Env.sublime-build', 'dotfiles-master/settings/VSCode-Keybindings.json', 'dotfiles-master/settings/VSCode-Settings.json', 'dotfiles-master/sublime.sh']
```


