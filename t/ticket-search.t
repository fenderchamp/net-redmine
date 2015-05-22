#!/usr/bin/env perl -w
use strict;
use Quantum::Superpositions;
use Test::Project;
use Net::Redmine;
use Test::More;

require 't/net_redmine_rest_test.pl';
my $r = new_net_redmine();

my ( $identifier, $name, $description, $homepage ) = project_test_data();

my $test_project = Test::Project->new(
    r           => $r,
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage,
    initialize  => 1
);


### Prepare new tickets. The default page size is 15. The number of
### tickets created here should be larger then that in order to prove
### that it crawls all pages of search results.

my @tickets = new_tickets($r, 20);

my @found = $r->search_ticket(__FILE__)->results;

ok( all( map { $_->id } @tickets ) == any(map { $_-> id } @found), "All the newly created issues can be found in the search result." );

$_->destroy for @tickets;

$test_project->scrub_project_if_exists;
