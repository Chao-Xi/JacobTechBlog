# re Module - How to Write and Match Regular Expressions (Regex)

Regular expressions are extremely useful for matching common patterns of text such as email addresses, phone numbers, URLs, etc.


## Rules and Policy

```
.       - Any Character Except New Line
\d      - Digit (0-9)
\D      - Not a Digit (0-9)
\w      - Word Character (a-z, A-Z, 0-9, _)
\W      - Not a Word Character
\s      - Whitespace (space, tab, newline)
\S      - Not Whitespace (space, tab, newline)

\b      - Word Boundary
\B      - Not a Word Boundary
^       - Beginning of a String
$       - End of a String

[]      - Matches Characters in brackets
[^ ]    - Matches Characters NOT in brackets
|       - Either Or
( )     - Group

Quantifiers:
*       - 0 or More
+       - 1 or More
?       - 0 or One
{3}     - Exact Number
{3,4}   - Range of Numbers (Minimum, Maximum)


#### Sample Regexs ####

[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+
```

## re Module with Regular Expressions

```
import re

text_to_search = '''
abcdefghijklmnopqurtuvwxyz
ABCDEFGHIJKLMNOPQRSTUVWXYZ
1234567890
Ha HaHa
MetaCharacters (Need to be escaped):
. ^ $ * + ? { } [ ] \ | ( )
google.com
321-555-4321
123.555.1234
123*555*1234
800-555-1234
900-555-1234
Mr. Schafer
Mr Smith
Ms Davis
Mrs. Robinson
Mr. T


sentence = 'Start a sentence and then bring it to an end'

```

### What is 'r' & 'R' prefix

When an 'r' or 'R' prefix is present, **a character following a backslash is included in the string without change, and all backslashes are left in the string**.

```
print('\tTab')

print(r'\tTab')
```

```
>>> 	Tab
>>>\tTab
```

### pattern.finditer(pattern, string, flags=0)

**Return an iterator yielding match objects over all non-overlapping matches for the RE pattern in string.** The string is scanned left-to-right, and matches are returned in the order found. Empty matches are included in the result.


### re.compile(pattern, flags=0)

**Compile a regular expression pattern into a regular expression object,**

* `pattern = re.compile(r'defined_pattern')`
* `matches =  pattern.finditer(insert_string)`
* `for math in matches:` 


```
pattern = re.compile(r'abc')

matches =  pattern.finditer(text_to_search)

for match in matches:
	print(match)
	
>>> <re.Match object; span=(1, 4), match='abc'>


print(text_to_search[1:4])

>>> abc
```

* Span is `defined_pattern` inside string **index**
* **match is matched string**
	

### How to apply `Rules and Policy`

#### 1.`$` => End of a String

```
pattern1 = re.compile(r'end$')
matches = pattern1.finditer(sentence)

for match in matches:
	print(match)

>>> <re.Match object; span=(139, 149), match='google.com'>
```

#### 2.`^` => Start of a String

```
pattern1 = re.compile(r'^Start')
matches = pattern1.finditer(sentence)

for match in matches:
	print(match)

>>> <re.Match object; span=(0, 5), match='Start'>
```

#### 3.'google\.com'=> If pattern with backslash

```
pattern2 = re.compile(r'google\.com')
matches = pattern2.finditer(text_to_search)

for match in matches:
	print(match)


>>> <re.Match object; span=(139, 149), match='google.com'>
```

#### 4.`\d`=> Digit (0-9)      `.` => Any Character Except New Line

```
pattern3 = re.compile(r'\d\d\d.\d\d\d.\d\d\d\d')
matches = pattern3.finditer(text_to_search)

for match in matches:
	print(match)

>>> <re.Match object; span=(150, 162), match='321-555-4321'>
>>> <re.Match object; span=(163, 175), match='123.555.1234'>
>>> <re.Match object; span=(176, 188), match='123*555*1234'>
>>> <re.Match object; span=(189, 201), match='800-555-1234'>
>>> <re.Match object; span=(202, 214), match='900-555-1234'>
```

#### 5.`[]` => Matches Characters in brackets

**16_data.txt**

```
Dave Martin
615-555-7164
173 Main St., Springfield RI 55924
davemartin@bogusemail.com

Charles Harris
800-555-5669
969 High St., Atlantis VA 34075
charlesharris@bogusemail.com

Eric Williams
560-555-5153
806 1st St., Faketown AK 86847
laurawilliams@bogusemail.com

Corey Jefferson
900-555-9340
826 Elm St., Epicburg NE 10671
coreyjefferson@bogusemail.com

Jennifer Martin-White
714-555-7405
212 Cedar St., Sunnydale CT 74983
jenniferwhite@bogusemail.com

Erick Davis
800-555-6771
519 Washington St., Olympus TN 32425
tomdavis@bogusemail.com
...
```

```
pattern4 = re.compile(r'\d{3}[-.]\d{3}[-.]\d{4}')

with open('16_data.txt', 'r') as f:
	contents = f.read()
	
	matches = pattern4.finditer(contents)

	for match in matches:
		print(match)
		
>>> <re.Match object; span=(12, 24), match='615-555-7164'>
>>> <re.Match object; span=(102, 114), match='800-555-5669'>
>>> <re.Match object; span=(191, 203), match='560-555-5153'>
>>> <re.Match object; span=(281, 293), match='900-555-9340'>
>>> <re.Match object; span=(378, 390), match='714-555-7405'>
...
```

#### 5.`[89]` => Matches 8 or 9

```
pattern5 = re.compile(r'[89]00[-.]\d\d\d[-.]\d\d\d\d')
# match start number with 800 or 900


with open('16_data.txt', 'r', encoding='utf-8') as f:
	contents = f.read()

	matches = pattern5.finditer(contents)

	for match in matches:
		print(match)

>>> <re.Match object; span=(102, 114), match='800-555-5669'>
>>> <re.Match object; span=(281, 293), match='900-555-9340'>
>>> <re.Match object; span=(467, 479), match='800-555-6771'>
>>> <re.Match object; span=(1091, 1103), match='900-555-3205'>
>>> <re.Match object; span=(1439, 1451), match='800-555-6089'>
...
```

#### 5.`[1-5]` => Matches from 1 two 5

```
pattern5 = re.compile(r'[1-5]00[-.]\d\d\d[-.]\d\d\d\d')

# match start number from 100 to 500

with open('16_data.txt', 'r', encoding='utf-8') as f:
	contents = f.read()

	#matches = pattern3.finditer(contents)
	matches = pattern5.finditer(contents)

	for match in matches:
		print(match)

>>> <re.Match object; span=(5830, 5842), match='400-555-1706'>
>>> <re.Match object; span=(7953, 7965), match='300-555-7821'>
```

#### 6 `|` as options, `?` for 0 or one, `\w`  for Word Character (a-z, A-Z, 0-9, _), `*` for 0 or More

```
pattern6 = re.compile(r'M(r|s|rs)\.?\s[A-Z]\w*')

matches = pattern6.finditer(text_to_search)

for match in matches:
	print(match)
	
>>> <re.Match object; span=(215, 226), match='Mr. Schafer'>
>>> <re.Match object; span=(227, 235), match='Mr Smith'>
>>> <re.Match object; span=(236, 244), match='Ms Davis'>
>>> <re.Match object; span=(245, 258), match='Mrs. Robinson'>
>>> <re.Match object; span=(259, 264), match='Mr. T'>
```

### pattern.findall(string, flags=0)

**Return all non-overlapping matches of pattern in string, as a list of strings**. 

```
pattern8  = re.compile(r'\d{3}.\d{3}.\d{4}')

matches = pattern8.findall(text_to_search)

for match in matches:
	print(match)
	
>>> 321-555-4321
>>> 123.555.1234
>>> 123*555*1234
>>> 800-555-1234
>>> 900-555-1234
```

### pattern.match(string, flags=0)

**If zero or more characters at the beginning of string match the regular expression pattern, return a corresponding match object. Return None if the string does not match the pattern;** 

```
pattern9  = re.compile(r'Start')

matches = pattern9.match(sentence)   # only print first

print(matches)

>>> <re.Match object; span=(0, 5), match='Start'>
```

### `re.IGNORECASE` Perform case-insensitive matching; expressions like [A-Z] will also match lowercase letters. 

### `pattern.search(string)` Scan through string looking for the first location where the regular expression pattern produces a match, and return a corresponding match object.

```
pattern10  = re.compile(r'START', re.IGNORECASE)

matches = pattern10.search(sentence)  # can search all in sentence

print(matches)

<re.Match object; span=(0, 5), match='Start'>
```

## Regex with Email

```
import re

emails = '''
CoreyMSchafer@gmail.com
corey.schafer@university.edu
corey-321-schafer@my-work.net
'''
```
#### pattern1

```
pattern1=re.compile(r'[a-zA-Z]+@[a-zA-Z]+\.com')


for match in matches:
	print(match)
	
	
>>> <re.Match object; span=(1, 24), match='CoreyMSchafer@gmail.com'>
```

#### pattern2

```
pattern2=re.compile(r'[a-zA-Z]+@[a-zA-Z]+\.(com|edu)')

>>> # <re.Match object; span=(1, 24), match='CoreyMSchafer@gmail.com'>
>>> # <re.Match object; span=(31, 53), match='schafer@university.edu'>
```

#### pattern3

```
pattern3=re.compile(r'[a-zA-Z0-9.-]+@[a-zA-Z-]+\.(com|edu|net)')

>>> <re.Match object; span=(1, 24), match='CoreyMSchafer@gmail.com'>
>>> <re.Match object; span=(25, 53), match='corey.schafer@university.edu'>
>>> <re.Match object; span=(54, 83), match='corey-321-schafer@my-work.net'>
```

#### patter4 

```
patter4 = re.compile(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+')

>>> <re.Match object; span=(1, 24), match='CoreyMSchafer@gmail.com'>
>>> <re.Match object; span=(25, 53), match='corey.schafer@university.edu'>
>>> <re.Match object; span=(54, 83), match='corey-321-schafer@my-work.net'>
```


## Regex with URL

```
import re

urls = '''
https://www.google.com
http://coreyms.com
https://youtube.com
https://www.nasa.gov
'''
```

* `s?`: 0 or one s
* `(www\.)?`: 0  or one (www) with "."
* `(\w+)`: 1 or more **Word Character**
* `(\.\w+)`: "." with 1 or more **Word Character**

```
pattern = re.compile(r'https?://(www\.)?(\w+)(\.\w+)') 


for match in matches:
	print(match.group(0))
	
>>>https://www.google.com
>>>http://coreyms.com
>>>https://youtube.com
>>>https://www.nasa.gov
```

```
print(match.group(1))

>>> www.
>>> None
>>> None
>>> www.
```

```
print(match.group(2))

>>> google
>>> coreyms
>>> youtube
>>> nasa
```

```
print(match.group(3))
>>> .com
>>> .com
>>> .com
>>> .gov
```

### match group 2 and group 3 simultaneously

### pattern.sub() Return the string obtained by replacing the leftmost non-overlapping occurrences of pattern in string by the replacement repl. 

```
subbed_urls = pattern.sub(r'\2\3', urls)
print(subbed_urls)

>>> google.com
>>> coreyms.com
>>> youtube.com
>>> nasa.gov
```




























