#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest;
use Test::Project;
use Net::RedmineRest::Project;
use Net::RedmineRest::IssueList;
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

my $project_id=$test_project->id;

### Prepare new tickets
my @tix=new_tickets($r, 2);

my $issue_list=Net::RedmineRest::IssueList->load( 
   connection=>$r->connection,
   project_id=>$project_id
);
is($issue_list->count, 2, "2 tickets in list");

undef $r;
$r = new_net_redmine();

my $project=Net::RedmineRest::Project->load(
   id=>$project_id,
   connection=>$r->connection
);
is(scalar @{$project->issues}, 2, "2 tickets in list");
$project->destroy();

