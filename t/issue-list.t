#!/usr/bin/env perl -w
use strict;
use Net::Redmine;
use Net::Redmine::Project;
use Net::Redmine::IssueList;
use Test::More;

use lib 't/lib';
use Test::Project;

my $test_project = Test::Project->new(
    initialize  => 1
);
my $r = $test_project->r;

my $project_id=$test_project->id;

### Prepare new tickets
my @tix=$test_project->new_tickets(2);

my $issue_list=Net::Redmine::IssueList->load( 
   connection=>$r->connection,
   project_id=>$project_id
);
is($issue_list->count, 2, "2 tickets in list");

undef $r;
my $tp = Test::Project->new();
$r = $tp->r;

my $project=Net::Redmine::Project->load(
   id=>$project_id,
   connection=>$r->connection
);
is(scalar @{$project->issues}, 2, "2 tickets in list");
$project->destroy();

