package Net::RedmineRest::IssueStatuses;
use Moo;
use Net::RedmineRest::Base;
extends 'Net::RedmineRest::Base';

my $SERVICE_NAME = 'issue_statuses';
has entity => ( is => "rw", default => ${SERVICE_NAME} );

has issue_statuses => ( is => "rw" );

#has _by_name        => ( is => "rw", default => { return {} } );
#has _by_id          => ( is => "rw", default => { return {} } );

has _by_name      => ( is => "rw", lazy=>1,builder => 1); 
has _by_id        => ( is => "rw", lazy=>1,builder => 1); 

sub _build__by_name { return {} };
sub _build__by_id { return {} };


sub _build_service {
    my ($self) = @_;
    return $self->entity();
}

sub _process_response {
    my ( $self, $code, $content ) = @_;
    if ( $code == 200 ) {
        $self->issue_statuses( $content->{issue_statuses} );
        $self->_load_xref();
        return $self;
    }
    return undef;
}

sub fetch {
    my ( $self, %args ) = @_;
    my $id   = $args{id};
    my $name = $args{name};
    return {} unless ( $id || $name );
    my $subscript;
    if ( $name ) {
        $name=lc($name);
        $subscript=$self->_by_name()->{$name};
    }
    elsif ($id) {
        $subscript=$self->_by_id()->{$id};
    } 

    return {} unless ( defined($subscript) && defined($self->issue_statuses->[$subscript]) );
    return $self->issue_statuses->[$subscript]; 
}



sub _load_xref {
    my ($self)=@_;
    if ( $self->issue_statuses ) {
        my $is      = $self->issue_statuses;
        my $by_name = $self->_by_name();
        my $by_id   = $self->_by_id();
        my $ctr=0;
        foreach my $issue_status (@$is) {
            my $n = lc($issue_status->{name});
            my $i = $issue_status->{id};
            $by_name->{$n} = $ctr;
            $by_id->{$i}   = $ctr;
            $ctr++;
        }
    }

}

#noops
sub save    { return undef }
sub create  { return undef }
sub destroy { return undef }

sub _has_required_load_args {
      return {};
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::RedmineRest::Project - Represents a project.

=head1 SYNOPSIS

Creating a project
POST /projects.json
Parameters:

project (required): a hash of the project attributes, including:
  name (required): the project name
  identifier (required): the project identifier
  description
  homepage
  is_public: true or false
  parent_id: the parent project number
  inherit_members: true or false
  tracker_ids: (repeatable element) the tracker id: 1 for Bug, etc.
  enabled_module_names: (repeatable element) the module name: boards, calendar, documents, files, gantt, issue_tracking, news, repository, time_tracking, wiki.
  


=head1 DESCRIPTION



=cut
