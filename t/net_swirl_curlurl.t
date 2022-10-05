use Test2::V0 -no_srand => 1;
use Net::Swirl::CurlURL;

subtest 'basic' => sub {

  my $url = Net::Swirl::CurlURL->new;

  isa_ok $url, 'Net::Swirl::CurlURL';

  $url->url('http://roger:foo@example.test/bar/baz?x=1#frag');

  is( $url->url, 'http://roger:foo@example.test/bar/baz?x=1#frag', 'get whole URL' );
  is( "$url",    'http://roger:foo@example.test/bar/baz?x=1#frag', 'get whole URL by stringifiying' );

  is( $url->scheme,   'http',         'get scheme'   );
  is( $url->user,     'roger',        'get user'     );
  is( $url->password, 'foo',          'get password' );
  is( $url->host,     'example.test', 'get host'     );
  is( $url->path,     '/bar/baz',     'get path'     );
  is( $url->query,    'x=1',          'get query'    );
  is( $url->fragment, 'frag',         'get fragment' );

  is( $url->host('another.test'), 'another.test', 'set host');

  is( $url->url, 'http://roger:foo@another.test/bar/baz?x=1#frag', 'get whole URL after modification' );

  $url->flags(Net::Swirl::CurlURL::CURLU_NON_SUPPORT_SCHEME);
  ok lives { $url->scheme('bogus') }, 'CURLU_NON_SUPPORT_SCHEME does not mind invalid scheme';

  my $url2 = $url->clone;

  ok lives { $url2->scheme('bogus') }, 'CURLU_NON_SUPPORT_SCHEME does not mind invalid scheme after clone';

};

subtest 'exceptions' => sub {

  subtest 'bad scheme?' => sub {

    is
      dies { Net::Swirl::CurlURL->new->scheme('bogus') },
      object {
        call [ isa => 'Net::Swirl::CurlURL::Exception' ] => T();
        call code => Net::Swirl::CurlURL::CURLUE_UNSUPPORTED_SCHEME;
      };

  };

  foreach my $name (sort { Net::Swirl::CurlURL->$a <=> Net::Swirl::CurlURL->$b } grep /^CURLUE_/, keys %Net::Swirl::CurlURL::)
  {
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

subtest 'import' => sub {

  package Test1 {
    use Net::Swirl::CurlURL ();
    Test2::V0::not_imported_ok 'CURLUE_OK';
    Test2::V0::not_imported_ok 'CURLU_DEFAULT_PORT';
  }

  package Test2 {
    use Net::Swirl::CurlURL qw( :all );
    Test2::V0::imported_ok 'CURLUE_OK';
    Test2::V0::imported_ok 'CURLU_DEFAULT_PORT';
  }

  package Test3 {
    use Net::Swirl::CurlURL qw( :errorcode );
    Test2::V0::imported_ok 'CURLUE_OK';
    Test2::V0::not_imported_ok 'CURLU_DEFAULT_PORT';
  }

  package Test4 {
    use Net::Swirl::CurlURL qw( :flags );
    Test2::V0::not_imported_ok 'CURLUE_OK';
    Test2::V0::imported_ok 'CURLU_DEFAULT_PORT';
  }

};

done_testing;
