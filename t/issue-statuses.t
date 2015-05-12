#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest;
use Test::More 'no_plan';

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();
my $is = $r->load_issue_statuses();

ok(scalar @{$is->issue_statuses},'some statuses loaded');

my $one=$is->issue_statuses->[0];

isa_ok ($is->fetch(id=>$one->{id}),'HASH','found id Hash');
is_deeply ($is->fetch(id=>$one->{id}),$one,'matches id Hash');

isa_ok ($is->fetch(name=>$one->{name}),'HASH','found name Hash');
is_deeply ($is->fetch(name=>$one->{name}),$one,'matches name Hash');
