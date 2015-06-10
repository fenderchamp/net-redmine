#!/usr/bin/env perl -w
use strict;
use Quantum::Superpositions;
use Net::Redmine;
use Net::Redmine::Search;
use Test::Cukes;

use lib 't/lib';
use Test::Project;
use Test::More;

my $search;
my @tickets;

my $test_project = Test::Project->new(
        initialize  => 1
    );

my $r=$test_project->r;
my $n = 2; 

Given qr/^that there are $n tickets in the system$/, sub {
    @tickets = $test_project->new_tickets( $n);

    assert @tickets == $n;
};

When qr/^searching with null query value$/, sub {
    $search = $r->search_ticket(undef);
};

Then qr/^all tickets should be found\.$/, sub {

    my @found = $search->results;
    assert(@found >= $n);

    diag("The total number of tickets is " . scalar(@found));

    my @ticket_ids = map { $_->id } @tickets;
    my @found_ids  = map { $_->id } @found;

    assert(all(@ticket_ids) == any(@found_ids));

    $_->destroy for @tickets;
    $test_project->scrub_project_if_exists();
};

runtests <<FEATURE;
Feature: Search with null query value
  A special case for search

  Scenario: Search with null query value
    Given that there are $n tickets in the system
    When searching with null query value
    Then all tickets should be found.
FEATURE
