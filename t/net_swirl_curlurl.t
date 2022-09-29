use Test2::V0 -no_srand => 1;
use Net::Swirl::CurlURL;

subtest 'basic' => sub {

  my $url = Net::Swirl::CurlURL->new;

  isa_ok $url, 'Net::Swirl::CurlURL';

  $url->url('http://roger:foo@example.test/bar/baz?x=1#frag');

  is( $url->url, 'http://roger:foo@example.test/bar/baz?x=1#frag' );

  is( $url->scheme,   'http'         );
  is( $url->user,     'roger'        );
  is( $url->password, 'foo'          );
  is( $url->host,     'example.test' );
  is( $url->path,     '/bar/baz'     );
  is( $url->query,    'x=1'          );
  is( $url->fragment, 'frag'         );

  is( $url->host('another.test'), 'another.test' );

  is( $url->url, 'http://roger:foo@another.test/bar/baz?x=1#frag' );

};

done_testing;


