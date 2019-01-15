# About Cookbook Versioning

A cookbook version represents a set of functionality that is different from the cookbook on which it is based. A version may exist for many reasons, such as ensuring the correct use of a third-party component, updating a bug fix, or adding an improvement. A cookbook version is defined using syntax and operators, may be associated with environments, cookbook metadata, and/or run-lists, and may be frozen (to prevent unwanted updates from being made).

A cookbook version is maintained just like a cookbook, with regard to source control, uploading it to the Chef server, and how the chef-client applies that cookbook when configuring nodes.

## Syntax

A cookbook version always takes the form `x.y.z`, where x, y, and z are decimal numbers that are used to represent `major (x)`, `minor (y)`, and `patch (z)` versions. A two-part version (x.y) is also allowed. **Alphanumeric version numbers (1.2.a3) and version numbers with more than three parts (1.2.3.4) are not allowed.**


## Constraints

```
operator cookbook_version_syntax
```

Operator  | Description
------------- | -------------
`=` | equal to
`>`  | greater than
`<` | less than
`>=` | greater than or equal to; also known as “optimistically greater than”, or “optimistic”
`<=` | less than or equal to
`~>`	| approximately greater than; also known as “pessimistically greater than”, or “pessimistic”


For example, a version constraint for “equals version 1.0.7” is expressed like this:

```
= 1.0.7
```

A version constraint for “greater than version 1.0.2” is expressed like this:

```
> 1.0.2
```

An optimistic version constraint is one that looks for versions greater than or equal to the specified version. For example:

```
>= 2.6.5
```

will match cookbooks greater than or equal to 2.6.5, such as 2.6.5, 2.6.7 or 3.1.1.

A pessimistic version constraint is one that will find the upper limit version number within the range specified by the minor version number or patch version number. For example, a pessimistic version constraint for minor version numbers:

```
~> 2.6
```

**will match cookbooks that are greater than or equal to version 2.6, but less than version 3.0.**

Or, a pessimistic version constraint for patch version numbers:

```
~> 2.6.5
```

**will match cookbooks that are greater than or equal to version 2.6.5, but less than version 2.7.0.**

Or, a pessimistic version constraint that matches cookbooks less than a version number:

```
< 2.3.4
```

or will match cookbooks less than or equal to a specific version number:

```
<= 2.6.5
```

## Metadata

Every cookbook requires a small amount of metadata. A file named `metadata.rb` is located at the top of every cookbook directory structure. The contents of the `metadata.rb` file provides information that helps **Chef Client and Server** correctly deploy cookbooks to each node.

Versions and version constraints can be specified in a cookbook’s `metadata.rb` file by using the following functions. Each function accepts a name and an optional version constraint; if a version constraint is not provided, `>= 0.0.0` is used as the default.

### `depends`

Show that a cookbook has a dependency on another cookbook. Use a version constraint to define dependencies for cookbook versions: `<` (less than), `<=` (less than or equal to), `=` (equal to), `>=` (greater than or equal to; also known as “optimistically greater than”, or “optimistic”), `~>` (approximately greater than; also known as “pessimistically greater than”, or “pessimistic”), or `>` (greater than). This field requires that a cookbook with a matching name and version exists on the Chef server. When the match exists, the Chef server includes the dependency as part of the set of cookbooks that are sent to the node when the chef-client runs. It is very important that the `depends` field contain accurate data. If a dependency statement is inaccurate, the chef-client may not be able to complete the configuration of the system. For example:	
```
depends 'opscode-base'
```
#### or:

```
depends 'opscode-github', '> 1.0.0'
```

#### or:

```
depends 'runit', '~> 1.2.3'
```

### `provides`

Add a recipe, definition, or resource that is provided by this cookbook, should the auto-populated list be insufficient.
	
### `supports`

Show that a cookbook has a supported platform. Use a version constraint to define dependencies for platform versions: `< `(less than), `<=` (less than or equal to), `=` (equal to), `>=` (greater than or equal to), `~>` (approximately greater than), or `>` (greater than). To specify more than one platform, use more than one supports field, once for each platform.

## Environments

An environment can use version constraints to specify a list of allowed cookbook versions by specifying the cookbook’s name, along with the version constraint. For example:

```
cookbook 'apache2', '~> 1.2.3'
```

Or:

```
cookbook 'runit', '= 4.2.0'
```

## Freeze Versions

A cookbook version can be frozen, which will prevent updates from being made to that version of a cookbook. (A user can always upload a new version of a cookbook.) Using cookbook versions that are frozen within environments is a reliable way to keep a production environment safe from accidental updates while testing changes that are made to a development infrastructure.

For example, to freeze a cookbook version using knife, enter:

```
$ knife cookbook upload redis --freeze
```

To return:

```
Uploading redis...
Upload completed
```

Once a cookbook version is `frozen`, only by using the `--force` option can an update be made. For example:

```
$ knife cookbook upload redis --force
```

Without the `--force` option specified, an error will be returned similar to:

```
Version 0.0.0 of cookbook redis is frozen. Use --force to override
```







