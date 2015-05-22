package Net::Redmine::Search;
use Moo;
use pQuery;
use Net::Redmine::Ticket;
use Text::CSV::Slurp;
use IO::String;
use Net::Redmine::Base;
extends 'Net::Redmine::Base';

has connection => (
    is => "rw",
    required => 0
);

has query => (is => "rw", required => 1);
has type => (is => "rw", required => 1);

sub results {
    my ($self) = @_;

    unless (defined($self->query)) {
        return $self->all_tickets;
    }
    my $mech = $self->connection->get_project_overview->mechanize;
    $mech->form_number(1);
    $mech->field(q => $self->query);
    $mech->submit;

    die "Failed on search page" unless $mech->response->is_success;

    my @r = ();

    do {
        pQuery($mech->content)->find("#search-results .issue a")->each(
            sub {
                my $issue_url = $_->getAttribute("href") or return;
                if (my ($issue_id) = $issue_url =~ m[/issues/(\d+)$]) {
                    push @r, Net::Redmine::Ticket->load(connection => $self->connection, id => $issue_id)
                }
            }
        );
    } while($mech->follow_link(text_regex => qr/Next/));

    return wantarray ? @r : \@r;
}

sub all_tickets {
    my ($self) = @_;

    my $project=Net::Redmine::Project->load(
         connection=>$self->connection
    );
    return @{$project->issues} if ($project);

    my $mech = $self->connection->get_issues_page->mechanize;

    unless ($mech->follow_link(text => "CSV")) {
        die "Fail to retrieve all tickets without CSV."
    }

    my $csv_content = $mech->content;
    my $csv_io = IO::String->new($csv_content);
    my $data = Text::CSV::Slurp->load(filehandle => $csv_io);
    my @r = ();
    foreach my $t (@$data) {
        push @r, Net::Redmine::Ticket->load(connection => $self->connection, id => $t->{'#'});
    }
    return wantarray ? @r : \@r;
}

__PACKAGE__->meta->make_immutable;
1;
