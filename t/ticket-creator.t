#!/usr/bin/env perl -w

use strict;
use Test::Cukes;
use Regexp::Common;
use Regexp::Common::Email::Address;
use Test::Project;
use Test::More;

require 't/net_redmine_rest_test.pl';

my $ticket_id;
my $test_project;
my $ticket_two;

Given qr/a ticket created by the current user/ => sub {

    my ( $identifier, $name, $description, $homepage ) = project_test_data();

    $test_project = Test::Project->new(
        r           => new_net_redmine(),
        identifier  => $identifier,
        name        => $name,
        description => $description,
        homepage    => $homepage,
        initialize  => 1
    );

    my ($ticket) = new_tickets($test_project->r, 1);
    $ticket_id = $ticket->id;

    assert $ticket_id =~ /^\d+$/;
};

When qr/the ticket object is loaded/ => sub {
    $ticket_two = $test_project->r->lookup(ticket => { id => $ticket_id });
    should $ticket_two->id, $ticket_id;
};

Then qr/its author should be the the current user/ => sub {
    assert $ticket_two->author->id =~ /^\d+$/;
    assert $ticket_two->author->email =~ /^$RE{Email}{Address}$/;
    $test_project->scrub_project_if_exists;
};


runtests(<<FEATURE);
Feature: know the creator of the ticket
  The creator (author) should be able to be retrieved from a ticket object

  Scenario: retrieve creator info from ticket
    Given a ticket created by the current user
    When the ticket object is loaded
    Then its author should be the the current user
FEATURE
