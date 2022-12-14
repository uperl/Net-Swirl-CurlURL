package Net::Swirl::CurlURL::FFI {

  use warnings;
  use 5.020;
  use FFI::CheckLib 0.30 qw( find_lib_or_die );

# ABSTRACT: Private class for Net::Swirl::CurlURL

=head1 SYNOPSIS

 $ perldoc Net::Swirl::CurlURL

=head1 DESCRIPTION

There is nothing to see here.  Please see the main documentation page at
L<Net::Swirl::CurlURL>.

=cut

  sub lib
  {
    $ENV{NET_SWIRL_CURL_DLL} // find_lib_or_die( lib => 'curl',  symbol => ['curl_url'], alien => ['Alien::curl'] );
  }

}

1;
