#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest::Ticket;
use Test::Project;
use Test::More;
use DateTime;

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

note "Testing about Net::RedmineRest::Ticket class";

my $subject = "Testing Net::RedmineRest $$ " . time;

note "The newly created ticket id should looks sane";

ok($r->connection->project(),'project found');
is($r->connection->project(),$identifier,'project found');

my $ticket = Net::RedmineRest::Ticket->create(
    connection => $r->connection,
    subject => $subject,
    description => "testing. testing. testing."
);
like $ticket->id, qr/^\d+$/;

$ticket->refresh;
# Given that this test doesn't run overnight.
is $ticket->created_at->ymd, DateTime->now->ymd;

note "Loading ticket content.";
my $ticket2 = Net::RedmineRest::Ticket->load(
    connection => $r->connection,
    id => $ticket->id
);

is($ticket2->id, $ticket->id);
is($ticket2->subject, $ticket->subject);
is($ticket2->description, $ticket->description);
