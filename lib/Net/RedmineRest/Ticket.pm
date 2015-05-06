package Net::RedmineRest::Ticket;
use Moo;
use Net::RedmineRest::TicketHistory;
use Net::RedmineRest::User;
use Net::RedmineRest::Project;
use DateTimeX::Easy;
use REST::Client;

my $SERVICE_NAME='issue';

has connection => (
    is => "rw",
    required => 1,
    weak_ref => 1,
);
has service     => (is => "rw", default=>$SERVICE_NAME);

has id          => (is => "rw");
has subject     => (is => "rw");
has description => (is => "rw");
has status      => (is => "rw");
has priority    => (is => "rw");
has author      => (is => "rw");
has created_at  => (is => "rw");
has note        => (is => "rw");
has project     => (is => "rw", lazy=>1, builder => 1);
has histories   => (is => "rw", lazy=>1, builder => 1);


sub _build_project {
#   my ($self)=@_;
#   my $project_identifier=$self->connection->project() 
#       if $self->connection && $self->connection->project(); 
#   return Net::RedmineRest::Project->load(
#      connection=>$self->connection,
#      identifier=>$project
#   );
}

sub create {
    my ($class, %attr) = @_;

    my $self = $class->new(%attr);

    my $c=$self->connection;

    my $data=$self->_provide_default_data();

    my $project=$self->project();
    die 'need associated project to create issue/ticket' unless ($project);
    my $project_id=$project->id();
    $data->{project_id}=$project_id;

    my $content;
    $content->{$self->service()}=$data;
    my ($code,$response) = $c->POST(
         service=>$self->service,
         content=>$content
    );

}

# use IO::All;
use pQuery;
use HTML::WikiConverter;
use Encode;

sub load {
    my ($class, %attr) = @_;
    die "should specify ticket id when loading it." unless defined $attr{id};
    die "should specify connection object when loading tickets." unless defined $attr{connection};

    my $live = $attr{connection}->_live_ticket_objects;
    my $id = $attr{id};
    return $live->{$id} if exists $live->{$id};

    my $self = $class->new(%attr);
    $self->refresh or return;

    $live->{$self->id} = $self;
    return $self;
}

sub refresh {
    my ($self) = @_;
    die "Cannot lookup ticket histories without id.\n" unless $self->id;

    my $id = $self->id;
    eval '$self->connection->get_issues_page($id)';
    if ($@) { warn $@; return }

    my $p = pQuery($self->connection->mechanize->content);
    my $wc = new HTML::WikiConverter( dialect => 'Markdown' );
    my $description = $wc->html2wiki( Encode::encode_utf8($p->find(".issue .wiki")->html) );
    my $subject = $p->find(".issue h3")->text;
    my $status = $p->find(".issue .status")->eq(1)->text;

    $self->subject($subject);
    $self->description($description);
    $self->status($status);

    $self->created_at(DateTimeX::Easy->new( $p->find(".issue .author a")->get(1)->getAttribute("title") ));

    my $author_page_uri = $p->find(".issue .author a")->get(0)->getAttribute("href");
    if ($author_page_uri =~ m[/(?:account/show|users)/(\d+)$]) {
        $self->author(Net::RedmineRest::User->load(id => $1, connection => $self->connection));
    }

    return $self;
}

sub save {
    my ($self) = @_;
    die "Cannot save a ticket without id.\n" unless $self->id;

    my $mech = $self->connection->get_issues_page($self->id)->mechanize;
    $mech->follow_link( url_regex => qr[/issues/\d+/edit$] );

    $mech->form_id("issue-form");
    $mech->set_fields(
        'issue[status_id]' => $self->status,
        'issue[description]' => $self->description,
        'issue[subject]' => $self->subject
    );

    if ($self->note) {
        $mech->set_fields(notes => $self->note);
    }

    $mech->submit;
    die "Ticket save failed (ticket id = @{[ $self->id ]})\n"
        unless $mech->response->is_success;

    return $self;
}

sub destroy {
    my ($self) = @_;
    die "Cannot delete the ticket without id.\n" unless $self->id;

    my $id = $self->id;

    $self->connection->get_issues_page($id);

    my $mech = $self->connection->mechanize;
    my $link = $mech->find_link(url_regex => qr[/issues/${id}/destroy$]);

    die "You cannot delete the ticket $id.\n" unless $link;

    my $html = $mech->content;
    my $delete_form = "<form name='net_redmine_delete_issue' method=\"POST\" action=\"@{[ $link->url_abs ]}\"><input type='hidden' name='_method' value='post'></form>";
    $html =~ s/<body>/<body>${delete_form}/;
    $mech->update_html($html);

    $mech->form_number(1);
    $mech->submit;

    die "Failed to delete the ticket\n" unless $mech->response->is_success;

    $self->id(-1);

    my $live = $self->connection->_live_ticket_objects;
    delete $live->{$id};

    return $self;
}

sub _build_histories {
    my ($self) = @_;
    die "Cannot lookup ticket histories without id.\n" unless $self->id;
    my $mech = $self->connection->get_issues_page($self->id)->mechanize;

    my $p = pQuery($mech->content);

    my $n = $p->find(".journal")->size;

    return [
        map {
            Net::RedmineRest::TicketHistory->new(
                connection => $self->connection,
                id => $_,
                ticket_id => $self->id
            )
        } (0..$n)
    ];
}

sub _provide_default_data { 
    #my $data;
    #$data->{description}=$self->description;
    ##$data->{tracker_id}=1;
    ##$data->{status_id}=1;
    ##$data->{priority_id}=1;
    #$data->{description}=1;
    ##$data->{category_id}=1;
    #return $data;
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::RedmineRest::Ticket - Represents a ticket.

=head1 SYNOPSIS

Creating an issue
POST /issues.[format]
Parameters:

issue - A hash of the issue attributes:
project_id
tracker_id
status_id
priority_id
subject
description
category_id
fixed_version_id - ID of the Target Versions (previously called 'Fixed Version' and still referred to as such in the API)
assigned_to_id - ID of the user to assign the issue to (currently no mechanism to assign by name)
parent_issue_id - ID of the parent issue
custom_fields - See Custom fields
watcher_user_ids - Array of user ids to add as watchers (since 2.3.0)
is_private - Use true or false to indicate whether the issue is private or not
estimated_hours - Number of hours estimated for issue



=head1 DESCRIPTION



=cut
