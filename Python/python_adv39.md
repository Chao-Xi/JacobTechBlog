# Visual Studio Code (Mac) - Setting up a Python Development Environment and Complete


## Test Python code

```
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
```


## Python Extension

### Change color theme

```
command+shift+p => color theme => change color theme and install new setting
```

### change file icon

```
command+shift+p => file icon => install new icon: Vscode icon

```

### Code Runner Extension

```
extension => install 'code runner' 
```

#### Change settings for code runner 

Add json code below to `settings.json`

```
 "code-runner.executorMap": {
        "python": "$pythonPath -u $fullFileName"
    },
"code-runner.showExecutionMessage": false,
"code-runner.clearPreviousOutput": true
```

`ctrl+alt(option)+N => run the code `


## Open default setting in JSON

```
command+shift+p => open default setting in JSON
```

### Set Default Python

```
settings icon => search (python.p) => set python path
```

### quick open terminal 

```
ctrl + ` => quick open terminal
```

### Code Formatting

```
format code manually: shit+option(alt)+F => install "black"
```

### Code Linting

```
command+shift+p => pylint => enable pylint
```

#### Current `settings.json` and keep updating

```
{
    "editor.fontSize": 18,
    "workbench.colorTheme": "One Dark Pro Vivid",
    "workbench.iconTheme": "vscode-icons",
    "terminal.integrated.fontSize": 15,
    "python.pythonPath": "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3",
    "code-runner.executorMap": {
        "python": "$pythonPath -u $fullFileName"
    },
    "code-runner.showExecutionMessage": false,
    "code-runner.clearPreviousOutput": true
}
```



## Debugging

```
debug button =>  add configuration => python file
```

