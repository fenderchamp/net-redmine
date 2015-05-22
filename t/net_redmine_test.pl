use Test::More;
use Cwd 'getcwd';


END {
    # system "kill -9 $REDMINE_SERVER_PID" if $REDMINE_SERVER_PID
}

sub net_redmine_test {
    return ("http://demo.redmin.org", "admin", "admin");
}

sub new_net_redmine {
    my ($server, $user, $password) = ("http://netredmine.m.redmine.org", "net-redmine-unit-tests", "net-redmine-unit-tests");
    return Net::Redmine->new(url => $server.'/projects/test',user => $user, password => $password);
}

use Text::Greeking;

sub new_tickets {
    my ($r, $n) = @_;
    $n ||= 1;

    my $g = Text::Greeking->new;
    $g->paragraphs(1,1);
    $g->sentences(1,1);
    $g->words(8,24);

    my (undef, $filename, $line) = caller;

    return map {
        $r->create(
            ticket => {
                subject => "$filename, line $line " . $g->generate,
                description => $g->generate
            }
        );
    } (1..$n);
}

1;
