package Net::Swirl::CurlURL {

  use strict;
  use warnings;
  use 5.020;
  use Net::Swirl::CurlURL::FFI;
  use FFI::Platypus 2.00;
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

=cut

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
  $ffi->attach( [ cleanup => 'DESTROY' ] => ['CURLU'] );
  $ffi->attach( [ dup => 'clone' ] => ['CURLU'] => 'CURLU' );

  $ffi->attach( [ get => '_get' ] => ['CURLU','enum','string*','uint'] => 'enum');
  $ffi->attach( [ set => '_set' ] => ['CURLU','enum','string','uint' ] => 'enum');

  {
    my $count = 0;
    foreach my $name (qw( url scheme user password options host port path query fragment zoneid ))
    {
      my $id = $count;
      my $code = sub {
        my $self = shift;
        if(@_) {
          my $code = _set($self, $id, $_[0], 0);
          Net::Swirl::CurlURL::Exception->throw(code => $code ) if $code != 0;
        }
        my $code = _get($self, $id, \my $value, 0);
        Net::Swirl::CurlURL::Exception->throw(code => $code ) if $code != 0;
        $value;
      };
      $count++;
      no strict 'refs';
      *{$name} = $code;
    }
  }

}

1;

=head1 SEE ALSO

=over 4

=item L<Net::Swirl::CurlEasy>

=back

=cut
