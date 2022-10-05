# Net::Swirl::CurlURL ![static](https://github.com/uperl/Net-Swirl-CurlURL/workflows/static/badge.svg) ![linux](https://github.com/uperl/Net-Swirl-CurlURL/workflows/linux/badge.svg)

Perl interface to curl's URL object

# SYNOPSIS

```perl
use Net::Swirl::CurlURL;

my $url = Net::Swirl::CurlURL->new;
$url->scheme('https');
$url->host('localhost');

say $url->url;    # http://localhost
say "$url";       # http://localhost

say $url->host;   # localhost
```

# DESCRIPTION

This is an interface to `libcurl`'s URL API.  It may be useful in
combination with [Net::Swirl::CurlEasy](https://metacpan.org/pod/Net::Swirl::CurlEasy), which has options that will
take objects of this class.

# CONSTRUCTOR

## new

```perl
my $url = Net::Swirl::CurlURL->new;
```

Creates a new instance of the class.

# METHODS

## clone

```perl
my $url2 = $url->clone;
```

Creates a new instance of the class, with the same values.

## url

```perl
my $string = $url->url;
my $string = "$url";
```

Returns the stringified version of the URL.

## scheme

```perl
my $scheme = $url->scheme;
```

Returns the scheme.

## user

```perl
my $user = $url->user;
```

Returns the user.

## password

```perl
my $pass = $url->password;
```

Returns the password.

## options

```perl
my $options = $url->options;
```

Returns the options.

## host

```perl
my $host = $url->host;
```

Returns the host.

## port

```perl
my $port = $url->port;
```

Returns the port.

## path

```perl
my $path = $url->path;
```

Returns the path.

## query

```perl
my $query = $url->query;
```

Returns the query.

## fragment

```perl
my $fragment = $url->fragment;
```

Returns the fragment.

## zoneid

```perl
my $zoneid = $url->zoneid;
```

Returns the zoneid.

# EXCEPTIONS

If an error is detected, it will be thrown as a `Net::Swirl::CurlURL::Exception`.
This is a subclass of [Exception::FFI::ErrorCode](https://metacpan.org/pod/Exception::FFI::ErrorCode).  The error codes can be imported
from this module with the `:errorcode` tag.  Example:

```perl
use Net::Swirl::CurlURL qw( :errorcode );
try {
  my $url = Net::Swirl::CurlURL->new;
  $url->scheme('bogus');
} catch ($e) {
  if($e isa Net::Swirl::CurlURL::Exception) {
    if($e->code == CURLUE_UNSUPPORTED_SCHEME) {
    }
  }
}
```

# SEE ALSO

- [Net::Swirl::CurlEasy](https://metacpan.org/pod/Net::Swirl::CurlEasy)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2022 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
