package Net::Redmine::ProjectList;
use Moo;
use Net::Redmine::Base;
extends 'Net::Redmine::Base';

my $SERVICE_NAME='project';
has  entity   => ( is=>"rw",default=>${SERVICE_NAME});
has  projects => ( is=>"rw");

sub _process_response {
    my ($self,$code,$content)=@_;
    if ( $code == 200 ) {
      $self->projects($content->{projects});
      return $self;
    }
    return undef;
}

#noops
sub save    { return undef };
sub create  { return undef };
sub destroy { return undef };

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Redmine::Project - Represents a project.

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
