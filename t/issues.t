#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest;
use Net::RedmineRest::Issue;
use Net::RedmineRest::Simple;
use DateTime;
use Test::Project;
use Test::More;

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();

my ( $identifier, $name, $description, $homepage ) = project_test_data();

my $t = Test::Project->new(
    r           => $r,
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage
);

$t->scrub_project_if_exists();
my $p=$t->create_project_and_verify_its_there();

my $subject = "Testing Net::RedmineRest $$ " . time;

my $issue = Net::RedmineRest::Issue->create(
    connection => $r->connection,
    project => $p,
    subject => $subject,
    description => "issue $description",
    tracker =>
      Net::RedmineRest::Simple->new(
         name=>'bug', 
         id=>1 
      ),
    priority => 
      Net::RedmineRest::Simple->new(
         name=>'normal', 
         id=>2 
      ),
    status => 
       Net::RedmineRest::Simple->new(
         name=>'new', 
         id=>1 
      ),
);

ok ($issue->id =~ /^\d+$/,'id is numeric');

# Given that this test doesn't run overnight.
is($issue->created_at->ymd, DateTime->now->ymd, 'date as expected');

$DB::single=1;
my $issue2 = Net::RedmineRest::Issue->load(
    connection => $r->connection,
    id => $issue->id
);
$DB::single=1;

is($issue2->id, $issue->id,'issue ids match');
is($issue2->subject, $issue->subject,'issue subjects match');
is($issue2->description, $issue->description,'issue descriptions match');
isa_ok($issue2->project, 'Net::RedmineRest::Project', 'proper project object found on issue after load');
isa_ok($issue2->author, 'Net::RedmineRest::User', 'proper user object found on issue after load');

$issue2->destroy;

undef($issue2);

$issue2 = Net::RedmineRest::Issue->load(
    connection => $r->connection,
    id => $issue->id
);

is($issue2,undef,'no issue after destroy');
$t->scrub_project_if_exists();


