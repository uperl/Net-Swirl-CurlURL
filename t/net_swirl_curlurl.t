use Test2::V0 -no_srand => 1;
use Net::Swirl::CurlURL;

subtest 'basic' => sub {

  my $url = Net::Swirl::CurlURL->new;

  isa_ok $url, 'Net::Swirl::CurlURL';

  $url->url('http://roger:foo@example.test/bar/baz?x=1#frag');

  is( $url->url, 'http://roger:foo@example.test/bar/baz?x=1#frag', 'get whole URL' );

  is( $url->scheme,   'http',         'get scheme'   );
  is( $url->user,     'roger',        'get user'     );
  is( $url->password, 'foo',          'get password' );
  is( $url->host,     'example.test', 'get host'     );
  is( $url->path,     '/bar/baz',     'get path'     );
  is( $url->query,    'x=1',          'get query'    );
  is( $url->fragment, 'frag',         'get fragment' );

  is( $url->host('another.test'), 'another.test', 'set host');

  is( $url->url, 'http://roger:foo@another.test/bar/baz?x=1#frag', 'get whole URL after modification' );

};

subtest 'exceptions' => sub {

  foreach my $name (sort keys %Net::Swirl::CurlURL::)
  {
    next unless $name =~ /^CURLUE_/;
    subtest $name => sub {

      my $code = Net::Swirl::CurlURL->$name;

      my $ex = dies { Net::Swirl::CurlURL::Exception->throw(code => $code) };

      is
        $ex,
        object {
          call [ isa => 'Net::Swirl::CurlURL::Exception' ] => T();
          call code => $code;
        },
        'throws';

      note "name = $name";
      note "code = $code";
      note "diag = @{[ $ex->strerror ]}";


    };
  }
};

done_testing;


