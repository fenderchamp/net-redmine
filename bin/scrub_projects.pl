#!/usr/bin/env perl -w
use strict;
use Net::Redmine;

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();

my $projects=$r->load_projects();

foreach my $json (@$projects) {
    next unless ( $json->{identifier} =~ /^test\d+/ );
    my $project=$r->lookup_project( identifier => $json->{identifier});
    $project->destroy;

}


