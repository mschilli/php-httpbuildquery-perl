# Copyright (c) 2008 Yahoo! Inc.  All rights reserved.  The
# copyrights to the contents of this file are licensed under the Perl
# Artistic License (ver. 15 Aug 1997)

######################################################################
# Test suite for PHP::HTTPBuildQuery
######################################################################
use warnings;
use strict;

use PHP::HTTPBuildQuery qw(http_build_query http_build_query_utf8);
use Test::More;
use URI::Escape;

$PHP::HTTPBuildQuery::SORTED_HASH_KEYS = 1;

plan tests => 14;

is( http_build_query( 
      { foo => { 
          bar   => "baz", 
          quick => { "quack" => "schmack" },
        },
      },
    ),
    cobble("foo[bar]=baz", "foo[quick][quack]=schmack"),
    "pod"
);

is( http_build_query( ['foo', 'bar'], "name" ),
    "name_0=foo&name_1=bar",
    "array at top level"
);

is( http_build_query( ['foo', 'bar'] ),
    "0=foo&1=bar",
    "array at top level"
);

is( http_build_query( { foo => "bar" } ), 
    "foo=bar",
    "simple hash"
);

is( http_build_query( { foo => { "bar" => "baz" }} ), 
    cobble("foo[bar]=baz"),
    "nested hash"
  );

is( http_build_query( { foo => { "bar" => { quick => "quack" }}} ), 
    cobble("foo[bar][quick]=quack"),
    "nested hash"
  );

is( http_build_query( { foo => "bar", "baz" => "quack" } ),
    cobble("baz=quack", "foo=bar"),
    "two elements"
  );

is( http_build_query( { foo => "bar", "baz" => "quack", "me" => "you" } ),
    cobble("baz=quack", "foo=bar", "me=you"),
    "three elements"
  );

is( http_build_query( { "foo%" => "bar" } ),
    "foo%25=bar",
    "urlesc in key"
  );

is( http_build_query( { "foo" => "ba%r" } ),
    "foo=ba%25r",
    "urlesc in value"
  );

is( http_build_query( { a => "b", c => { d => "e" } }, "foo" ),
    cobble("a=b", "c[d]=e"),
    "nested struct"
  );

is( http_build_query( { a => { 'b' => undef }, c => undef } ),
    cobble("a[b]=", "c="),
    'undefined scalars'
  );

is( http_build_query( 'id' ),
    '=id',
    'undefined sofar'
  );

use utf8;

is( http_build_query_utf8( ["\x{2013}foo", 'bar'] ),
    "0=%E2%80%93foo&1=bar",
    "utf8 char in array"
);

###########################################
sub cobble {
###########################################
    my(@fields) = @_;

    return join '&', map { escape_brackets( $_ ) } @fields;
}

###########################################
sub escape_brackets {
###########################################
    local($_) = $_[0];
    s/\[/%5B/g;
    s/\]/%5D/g;
    return $_;
}
