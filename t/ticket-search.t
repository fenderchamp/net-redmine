#!/usr/bin/env perl -w
use strict;
use Quantum::Superpositions;
use Net::Redmine;
use Test::More;

use lib 't/lib';
use Test::Project;
require 't/net_redmine_rest_test.pl';

my $test_project = Test::Project->new(
    initialize  => 1
);
my $r=$test_project->r;


### Prepare new tickets. The default page size is 15. The number of
### tickets created here should be larger then that in order to prove
### that it crawls all pages of search results.

my @tickets = $test_project->new_tickets(3);

my @found = $r->search_ticket(__FILE__)->results;

ok( all( map { $_->id } @tickets ) == any(map { $_-> id } @found), "All the newly created issues can be found in the search result." );

$_->destroy for @tickets;

$test_project->scrub_project_if_exists;
