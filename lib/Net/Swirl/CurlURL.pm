package Net::Swirl::CurlURL {

  use strict;
  use warnings;
  use 5.020;
  use Net::Swirl::CurlURL::FFI;
  use FFI::Platypus 2.00;
  use Exporter qw( import );
  use experimental qw( signatures postderef );

# ABSTRACT: Perl interface to curl's URL object

=head1 SYNOPSIS

 use Net::Swirl::CurlURL;
 
 my $url = Net::Swirl::CurlURL->new;
 $url->scheme('https');
 $url->host('localhost');
 
 say $url->url;    # http://localhost
 say "$url";       # http://localhost
 
 say $url->host;   # localhost

=head1 DESCRIPTION

This is an interface to C<libcurl>'s URL API.  It may be useful in
combination with L<Net::Swirl::CurlEasy>, which has options that will
take objects of this class.

=head1 CONSTRUCTOR

=head2 new

 my $url = Net::Swirl::CurlURL->new;

Creates a new instance of the class.

=head1 METHODS

=head2 clone

 my $url2 = $url->clone;

Creates a new instance of the class, with the same values.

=head2 url

 my $string = $url->url;
 my $string = "$url";

Returns the stringified version of the URL.

=head2 scheme

 my $scheme = $url->scheme;

Returns the scheme.

=head2 user

 my $user = $url->user;

Returns the user.

=head2 password

 my $pass = $url->password;

Returns the password.

=head2 options

 my $options = $url->options;

Returns the options.

=head2 host

 my $host = $url->host;

Returns the host.

=head2 port

 my $port = $url->port;

Returns the port.

=head2 path

 my $path = $url->path;

Returns the path.

=head2 query

 my $query = $url->query;

Returns the query.

=head2 fragment

 my $fragment = $url->fragment;

Returns the fragment.

=head2 zoneid

 my $zoneid = $url->zoneid;

Returns the zoneid.

=head2 flags

 my $old = $url->flags;
 $url->flags($new);

Get or set the flags.  The flags are bit mask that can be or'd together.  Symbolic
constants for the flags can be exported from this module using the C<:flags> import
tag.

=head1 EXCEPTIONS

If an error is detected, it will be thrown as a C<Net::Swirl::CurlURL::Exception>.
This is a subclass of L<Exception::FFI::ErrorCode>.  The error codes can be imported
from this module with the C<:errorcode> tag.  Example:

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

=cut

  our %flags;

  my $ffi = FFI::Platypus->new(
      api => 2,
      lib => [Net::Swirl::CurlURL::FFI->lib],
  );

  $ffi->type( 'object(Net::Swirl::CurlURL)' => 'CURLU' );
  $ffi->mangler(sub ($name) {
    $name eq 'new'
      ? 'curl_url'
      : "curl_url_$name" });

  package Net::Swirl::CurlURL::Exception {
    use Exception::FFI::ErrorCode
      const_class => 'Net::Swirl::CurlURL',
      codes => {
        CURLUE_OK                   => 0,
        CURLUE_BAD_HANDLE           => 1,
        CURLUE_BAD_PARTPOINTER      => 2,
        CURLUE_MALFORMED_INPUT      => 3,
        CURLUE_BAD_PORT_NUMBER      => 4,
        CURLUE_UNSUPPORTED_SCHEME   => 5,
        CURLUE_URLDECODE            => 6,
        CURLUE_OUT_OF_MEMORY        => 7,
        CURLUE_USER_NOT_ALLOWED     => 8,
        CURLUE_UNKNOWN_PART         => 9,
        CURLUE_NO_SCHEME            => 10,
        CURLUE_NO_USER              => 11,
        CURLUE_NO_PASSWORD          => 12,
        CURLUE_NO_OPTIONS           => 13,
        CURLUE_NO_HOST              => 14,
        CURLUE_NO_PORT              => 15,
        CURLUE_NO_QUERY             => 16,
        CURLUE_NO_FRAGMENT          => 17,
      };
    if($ffi->find_symbol('strerror'))
    {
      $ffi->attach( strerror => ['enum'] => 'string' => sub ($xsub, $self) {
        $xsub->($self->code);
      });
    }
  }

  $ffi->attach( new => [] => 'CURLU' );

  $ffi->attach( [ cleanup => 'DESTROY' ] => ['CURLU'] => sub ($xsub, $self) {
    delete $flags{$$self};
    $xsub->($self);
  });

  $ffi->attach( [ dup => 'clone' ] => ['CURLU'] => 'CURLU' => sub ($xsub, $self) {
    my $new = $xsub->($self);
    $flags{$$new} = $flags{$$self};
    $new;
  });

  $ffi->attach( [ get => '_get' ] => ['CURLU','enum','string*','uint'] => 'enum');
  $ffi->attach( [ set => '_set' ] => ['CURLU','enum','string', 'uint'] => 'enum');

  sub flags ($self, $new=undef)
  {
    $flags{$$self} = $new if defined $new;
    $flags{$$self}
  }

  {
    my $count = 0;
    foreach my $name (qw( url scheme user password options host port path query fragment zoneid ))
    {
      my $id = $count;
      my $code = sub {
        my $self = shift;
        if(@_) {
          my $code = _set($self, $id, $_[0], $flags{$$self});
          Net::Swirl::CurlURL::Exception->throw(code => $code ) if $code != 0;
        }
        my $code = _get($self, $id, \my $value, $flags{$$self});
        Net::Swirl::CurlURL::Exception->throw(code => $code ) if $code != 0;
        $value;
      };
      $count++;
      no strict 'refs';
      *{$name} = $code;
    }
  }

  use constant {
    CURLU_DEFAULT_PORT       => 1<<0,
    CURLU_NO_DEFAULT_PORT    => 1<<1,
    CURLU_DEFAULT_SCHEME     => 1<<2,
    CURLU_NON_SUPPORT_SCHEME => 1<<3,
    CURLU_PATH_AS_IS         => 1<<4,
    CURLU_DISALLOW_USER      => 1<<5,
    CURLU_URLDECODE          => 1<<6,
    CURLU_URLENCODE          => 1<<7,
    CURLU_APPENDQUERY        => 1<<8,
    CURLU_GUESS_SCHEME       => 1<<9,
    CURLU_NO_AUTHORITY       => 1<<10,
  };

  our @EXPORT_OK   = grep /^(CURLUE?_)/, sort keys %Net::Swirl::CurlURL::;
  our %EXPORT_TAGS = (
    all       => \@EXPORT_OK,
    errorcode => [ grep /^CURLUE_/, @EXPORT_OK ],
    flags     => [ grep /^CURLU_/ , @EXPORT_OK ],
  );

}

1;

=head1 SEE ALSO

=over 4

=item L<Net::Swirl::CurlEasy>

=back

=cut
