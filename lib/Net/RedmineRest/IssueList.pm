package Net::RedmineRest::IssueList;
use Moo;
use Net::RedmineRest::Base;
extends 'Net::RedmineRest::Base';

my $SERVICE_NAME='issues';
has  entity     => ( is=>"rw",default=>${SERVICE_NAME});
has  issues     => ( is=>"rw");
has  project_id => ( is=>"ro");

sub _build_service {
    my ($self)=@_;
   return $self->project_id.'/'.$self->intity();
}

sub _process_response {
    my ($self,$code,$content)=@_;
    if ( $code == 200 ) {
      return $self;
    }
    return undef;
}

#noops
sub save    { return undef };
sub create  { return undef };
sub destroy { return undef };

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
