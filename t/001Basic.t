# Copyright (c) 2008 Yahoo! Inc.  All rights reserved.  The
# copyrights to the contents of this file are licensed under the Perl
# Artistic License (ver. 15 Aug 1997)

######################################################################
# Test suite for PHP::HTTPBuildQuery
######################################################################
use warnings;
use strict;

use PHP::HTTPBuildQuery qw(http_build_query);
use Test::More qw(no_plan);
use URI::Escape;

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
    cobble("foo=bar", "baz=quack", ['foo', 'baz']),
    "two elements"
  );

is( http_build_query( { foo => "bar", "baz" => "quack", "me" => "you" } ),
    cobble("foo=bar", "baz=quack", "me=you",
           ['foo', 'baz', 'me']),
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
    cobble("a=b", "c[d]=e", ['a', 'c']),
    "nested struct"
  );

###########################################
sub cobble {
###########################################
    my(@fields) = @_;

    my $sort_order;

    if(ref ( $fields[-1] ) eq "ARRAY" ) {
        $sort_order = pop @fields;
    }

    @fields = hashsort(\@fields, $sort_order) if defined $sort_order;

    return join '&', map { escape_brackets( $_ ) } @fields;
}

###########################################
sub hashsort {
###########################################
    my($array, $hash_keys) = @_;

    my $i=0;
    my %order_hash = map { $_ => $i++ } @$hash_keys;

    my @copy = ();

    for my $key (keys %order_hash) {
        push @copy, $array->[ $order_hash{ $key } ];
    }

    return @copy; 
}

###########################################
sub escape_brackets {
###########################################
    local($_) = $_[0];
    s/\[/%5B/g;
    s/\]/%5D/g;
    return $_;
}
