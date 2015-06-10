#!/usr/bin/env perl -w
use strict;

use Net::Redmine;
use Net::Redmine::TicketHistory;
use Regexp::Common;
use Regexp::Common::Email::Address;
use DateTime;

use lib 't/lib';
use Test::Project;
use Test::More;

my $test_project = Test::Project->new(
    initialize  => 1
);

my $r=$test_project->r;
### Prepare a new ticket with multiple histories
my $t = $r->create(
    ticket => {
        subject => __FILE__ . " 1",
        description => __FILE__ . " (description)"
    }
);

$t->subject( $t->subject . " 2" );
$t->save;

$t->subject( $t->subject . " 3" );
$t->note("it is good. " . time);
$t->save;

# diag "Created a new ticket, id = " . $t->id;

### Examine its histories


{
    # The 0th history entry has a specially meaning of "ticket creation".
    my $h = Net::Redmine::TicketHistory->new(
        connection => $r->connection,
        id => 0,
        ticket_id => $t->id
    );

    isa_ok($h,'Net::Redmine::TicketHistory','th is a Net::Redmine::TicketHistory');

    like ($h->author->email, qr/^$RE{Email}{Address}$/,'email is sane for author');
    is($h->date->ymd, DateTime->now->ymd, 'th 0 date as expected');
    ok($h->can("ticket"),'ticket history has ticket method');

    my $prop = $h->property_changes;

    is_deeply(
        $prop->{subject},
        {
            from => "",
            to => __FILE__ . " 1",
        },
        'deeply property changes match whats expected'
    );

}

{
    my $h = Net::Redmine::TicketHistory->new(
        connection => $r->connection,
        id => 1,
        ticket_id => $t->id
    );


    isa_ok($h,'Net::Redmine::TicketHistory','th 1 is a Net::Redmine::TicketHistory');
    like ($h->author->email, qr/^$RE{Email}{Address}$/,'email 1 is sane for author');
    is($h->date->ymd, DateTime->now->ymd, 'th 1 date as expected');
    ok($h->can("journal"),'can journal');
    ok($h->can("ticket"),'can ticket');

    my $prop = $h->property_changes;

    is_deeply(
        $prop->{subject},
        {
            from => __FILE__ . " 1",
            to => __FILE__ . " 1 2",
        },
        'property_change 1 is good' 
    );

}


{
    my $h = Net::Redmine::TicketHistory->new(
        connection => $r->connection,
        id => 2,
        ticket_id => $t->id
    );
    ok($h->can("ticket"),'can ticket');

    like($h->note, qr/it is good. \d+/,'th 2 note matches');
    is($h->date->ymd, DateTime->now->ymd, 'th 2 date as expected');
    like ($h->author->email, qr/^$RE{Email}{Address}$/,'th 2 email is sane for author');

    my $prop = $h->property_changes;

    is_deeply(
        $prop->{subject},
        {
            from => __FILE__ . " 1 2",
            to => __FILE__ . " 1 2 3",
        },
        'property_change th 2 is good' 
    );

}

{
    my $histories = $t->histories;
    is(0+@$histories, 3, "This ticket has three history entires");

    foreach my $h (@$histories) {
        isa_ok($h,'Net::Redmine::TicketHistory','h is a Net::Redmine::TicketHistory');
        ok($h->can("id"),"can id ". $h->id);
        like($h->author->email, qr/^$RE{Email}{Address}$/, "examine ticket author email");
    }

    # require YAML;
    # die YAML::Dump($histories->[0]);
    is( $histories->[0]->date->ymd, DateTime->now->ymd, 'date 0 as expected ticket');
    is( $histories->[1]->date->ymd, DateTime->now->ymd, 'date 1 as expected journal 0');
    is( $histories->[2]->date->ymd, DateTime->now->ymd, 'date 2 as expected journal 1');

    is_deeply(
        $histories->[0]->property_changes->{subject},
        {
            from => "",
            to => __FILE__ . " 1",
        },
        'property_change th 0 is good' 
    );

    is_deeply(
        $histories->[1]->property_changes->{subject},
        {
            from => __FILE__ . " 1",
            to => __FILE__ . " 1 2",
        },
        'property_change th 1 is good' 
    );

    is_deeply(
        $histories->[2]->property_changes->{subject},
        {
            from => __FILE__ . " 1 2",
            to => __FILE__ . " 1 2 3",
        },
        'property_change th 2 is good' 
    );
}

$test_project->scrub_project_if_exists();
