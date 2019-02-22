# Prepare local Ruby environment

## Getting Started

```
$ sudo gem install bundler
```

Specify your dependencies in a Gemfile in your project's root:

```
mkdir plugin
```
```
$ ruby -v
ruby 2.3.7p456 (2018-03-28 revision 63024) [universal.x86_64-darwin18]
```

**`Gemfile`**

```
ruby '2.3.7'

source 'https://rubygems.org'

group :development do
  gem 'rubocop'
  gem 'pry'
end

gem 'aws-sdk-core'
gem 'hipchat'
gem 'thor'
gem 'net-ping'
gem 'require_all'
gem 'net-ssh-simple'
gem 'ridley'
gem 'rest-client'

# Constrain Hashie to version before https://github.com/intridea/hashie/pull/381
# was merged to prevent WARN log messages about conflicting method overrides.
gem 'hashie', '< 3.5.0'
```

**`Gemfile.lock`**

```
GEM
  remote: https://rubygems.org/
  specs:
    addressable (2.5.0)
      public_suffix (~> 2.0, >= 2.0.2)
    ast (2.3.0)
    aws-sdk-core (2.8.11)
      aws-sigv4 (~> 1.0)
      jmespath (~> 1.0)
    aws-sigv4 (1.0.0)
    blockenspiel (0.5.0)
    buff-config (2.0.0)
      buff-extensions (~> 2.0)
      varia_model (~> 0.6)
    buff-extensions (2.0.0)
    buff-ignore (1.2.0)
    buff-ruby_engine (1.0.0)
    buff-shell_out (1.1.0)
      buff-ruby_engine (~> 1.0)
    celluloid (0.16.0)
      timers (~> 4.0.0)
    celluloid-io (0.16.2)
      celluloid (>= 0.16.0)
      nio4r (>= 1.1.0)
    chef-config (12.19.36)
      addressable
      fuzzyurl
      mixlib-config (~> 2.0)
      mixlib-shellout (~> 2.0)
    coderay (1.1.1)
    domain_name (0.5.20170223)
      unf (>= 0.0.5, < 1.0.0)
    erubis (2.7.0)
    faraday (0.9.2)
      multipart-post (>= 1.2, < 3)
    fuzzyurl (0.9.0)
    hashie (3.4.6)
    hipchat (1.5.4)
      httparty
      mimemagic
    hitimes (1.2.4)
    http-cookie (1.0.3)
      domain_name (~> 0.5)
    httparty (0.14.0)
      multi_xml (>= 0.5.2)
    httpclient (2.8.3)
    jmespath (1.3.1)
    json (2.0.3)
    method_source (0.8.2)
    mime-types (3.1)
      mime-types-data (~> 3.2015)
    mime-types-data (3.2016.0521)
    mimemagic (0.3.2)
    mixlib-authentication (1.4.1)
      mixlib-log
    mixlib-config (2.2.4)
    mixlib-log (1.7.1)
    mixlib-shellout (2.2.7)
    multi_xml (0.6.0)
    multipart-post (2.0.0)
    net-ping (2.0.5)
    net-scp (1.2.1)
      net-ssh (>= 2.6.5)
    net-ssh (3.2.0)
    net-ssh-simple (1.6.17)
      blockenspiel (= 0.5.0)
      hashie (= 3.4.6)
      net-scp (= 1.2.1)
      net-ssh (= 3.2.0)
    netrc (0.11.0)
    nio4r (2.0.0)
    parser (2.4.0.0)
      ast (~> 2.2)
    powerpack (0.1.1)
    pry (0.10.4)
      coderay (~> 1.1.0)
      method_source (~> 0.8.1)
      slop (~> 3.4)
    public_suffix (2.0.5)
    rainbow (2.2.1)
    require_all (1.4.0)
    rest-client (2.0.1)
      http-cookie (>= 1.0.2, < 2.0)
      mime-types (>= 1.16, < 4.0)
      netrc (~> 0.8)
    retryable (2.0.4)
    ridley (5.1.0)
      addressable
      buff-config (~> 2.0)
      buff-extensions (~> 2.0)
      buff-ignore (~> 1.2)
      buff-shell_out (~> 1.0)
      celluloid (~> 0.16.0)
      celluloid-io (~> 0.16.1)
      chef-config (>= 12.5.0)
      erubis
      faraday (~> 0.9.0)
      hashie (>= 2.0.2, < 4.0.0)
      httpclient (~> 2.7)
      json (>= 1.7.7)
      mixlib-authentication (>= 1.3.0)
      retryable (~> 2.0)
      semverse (~> 2.0)
      varia_model (~> 0.6)
    rubocop (0.47.1)
      parser (>= 2.3.3.1, < 3.0)
      powerpack (~> 0.1)
      rainbow (>= 1.99.1, < 3.0)
      ruby-progressbar (~> 1.7)
      unicode-display_width (~> 1.0, >= 1.0.1)
    ruby-progressbar (1.8.1)
    semverse (2.0.0)
    slop (3.6.0)
    thor (0.19.4)
    timers (4.0.4)
      hitimes
    unf (0.1.4)
      unf_ext
    unf_ext (0.0.7.2)
    unicode-display_width (1.1.3)
    varia_model (0.6.0)
      buff-extensions (~> 2.0)
      hashie (>= 2.0.2, < 4.0.0)

PLATFORMS
  ruby

DEPENDENCIES
  aws-sdk-core
  hashie (< 3.5.0)
  hipchat
  net-ping
  net-ssh-simple
  pry
  require_all
  rest-client
  ridley
  rubocop
  thor

RUBY VERSION
   ruby 2.3.7p456

BUNDLED WITH
   2.0.1
```

**Install all of the required gems from your specified sources:**

```
$ sudo bundle install
```



