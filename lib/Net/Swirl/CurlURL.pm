package Net::Swirl::CurlURL {

  use strict;
  use warnings;
  use 5.020;
  use Net::Swirl::CurlURL::FFI;
  use FFI::Platypus 2.00;
  use experimental qw( signatures postderef );

# ABSTRACT: Perl interface to curl's URL object

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new

=head1 METHODS

=head2 clone

=head2 url

=head2 scheme

=head2 user

=head2 password

=head2 options

=head2 host

=head2 port

=head2 path

=head2 query

=head2 fragment

=head2 zoneid

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
