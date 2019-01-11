# knife search

Search indexes allow queries to be made for any type of data that is indexed by the Chef server, including data bags (and data bag items), environments, nodes, and roles. A defined query syntax is used to support search patterns like exact, wildcard, range, and fuzzy. 

## Syntax

This subcommand has the following syntax:

```
$ knife search INDEX SEARCH_QUERY
```

### INDEX

#### 1.client, environment, node, role or the name of a data bag 

#### 2.`SEARCH_QUERY` is the search query syntax for the query that will be executed.

#### 3.`INDEX` is implied if omitted, and will default to node. For example:

```
$ knife search '*:*' -i
```

is same search as 

```
$ knife search node '*:*' -i
```

### Query Syntax

A search query is comprised of two parts: the key and the search pattern. A search query has the following syntax:

```
key:search_pattern
```

### Keys

To search for the available fields for a particular object, use the show argument with any of the following knife subcommands: `knife client`, `knife data bag`, `knife environment`, `knife node`, or `knife role`. For example: `knife data bag show`.

### Examples

To use a question mark (`?`) to replace a single character in a wildcard search, enter the following:

```
$ knife search node 'platfor?:ubuntu'
```

To use an asterisk (`*`) to replace zero (or more) characters in a wildcard search, enter the following:

```
$ knife search node 'platfo*:ubuntu'
```

To find all IP address that are on the same network, enter the following:

```
$ knife search node 'ipaddress:192.168*'
```

To use a range search to find `IP addresses` within a `subnet`, enter the following:

```
$ knife search node 'ipaddress:[192.168.0.* TO 192.0.2.*]'
```

### About Patterns


#### Exact Matching

```
$ knife search admins 'id:charlie'
```

#### Wildcard Matching

* A question mark (`?`) can be used to replace exactly one character
* An asterisk (`*`) can be used to replace any number of characters (including zero)


```
$ knife search node 'foo:*'
```
```
$ knife search node 'name:app*'
```

```
$ knife search node 'name:app?.example.com'
```
```
$ knife search node 'name:app1.example.???'
```

#### Range Matching

A range matching search pattern is used to query for values that are within a range defined by upper and lower boundaries. A range matching search pattern can be inclusive or exclusive of the boundaries. Use square brackets (“`[ ]`”) to denote inclusive boundaries and curly braces (“`{ }`”) to denote exclusive boundaries and with the following syntax:

```
boundary TO boundary
```

**where `TO` is required (and must be capitalized).**

**To search using an inclusive range, enter the following:**

```
$ knife search sample "id:[bar TO foo]"
```
**To search using an exclusive range, enter the following:**

```
$ knife search sample "id:{bar TO foo}"
```

### About Operators

Operator  | Description
------------- | -------------
AND	 | Use to find a match when both terms exist.
OR	 | Use to find a match if either term exists.
NOT | Use to exclude the term after `NOT` from the search results.

#### AND 

```
$ knife search sample "id:b* AND animal:dog"
```
#### OR

```
$ knife search sample "id:foo OR id:abc"
```

### Options

`-a ATTR, --attribute ATTR`: The attribute (or attributes) to show.


`-i, --id-only`: Show only matching object IDs.

#### Search by platform ID

```
$ knife search node 'ec2:*' -i
```

#### Search by instance type

```
$ knife search node 'ec2:*' -a ec2.instance_type
```


#### Search by recipe

```
$ knife search node 'recipes:recipe_name'
```
or 

```
$ knife search node '*:*' -a recipes | grep 'recipe_name'
```



