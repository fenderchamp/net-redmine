#!/usr/bin/env perl -w
use strict;
use Test::Project;
use Quantum::Superpositions;
use Net::Redmine;
use Net::RedmineRest::Search;
use Test::Cukes;

require 't/net_redmine_rest_test.pl';
my $r = new_net_redmine();
my $search;
my @tickets;

my $test_project;

    my ( $identifier, $name, $description, $homepage ) = project_test_data();
    $test_project = Test::Project->new(
        r           => new_net_redmine(),
        identifier  => $identifier,
        name        => $name,
        description => $description,
        homepage    => $homepage,
        initialize  => 1
    );

my $r=$test_project->r;
my $n = int(rand(10)) + 3;

Given qr/^that there are $n tickets in the system$/, sub {
    @tickets = new_tickets($r, $n);

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
