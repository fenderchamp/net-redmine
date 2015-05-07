package Net::RedmineRest::Issue;
use Moo;
use Net::RedmineRest::Simple;
use Net::RedmineRest::User;
use Net::RedmineRest::TicketHistory;

use DateTimeX::Easy;

use Net::RedmineRest::Base;
extends 'Net::RedmineRest::Base';

my $ENTITY='issue';

has  entity => ( is=>"rw",default=>${ENTITY});

has additional_get_params => (
   is=>"rw",
   default=>'include=changesets,journals,watchers'
);

has assigned_to   => ( is=>"rw" );    #- ID of the user to assign the issue to (currently no mechanism to assign by name)
has author        => ( is=>"rw" );    #- ID of the user to assign the issue to (currently no mechanism to assign by name)
has category      => ( is=>"rw" );
has created_on    => ( is=>"rw" );

has created_at    => ( 
   is=>"rw", 
   lazy=>1, 
   builder=>1 
);

has description   => ( is=>"rw" );
has done_ratio    => ( is=>"rw" );
has due_date      => ( is=>"rw" );
has estimated_hours => ( is=>"rw" );   #- Number of hours estimated for issue
has fixed_version   => ( is=>"rw" );  #- ID of the Target Versions (previously called 'Fixed Version' and still referred to as such in the API)
has histories     => ( is=>"rw",lazy=>1, builder=>1 );
has id            => (is => "rw");
has is_private    => ( is=>"rw" );        # - Use true or false to indicate whether the issue is private or not

has notes          => ( is=>"rw" );        # - Use true or false to indicate whether the issue is private or not

has parent_issue  => ( is=>"rw" );
has priority      => ( is=>"rw" );
has project       => ( is=>"rw",lazy=>1,builder=>1 );
has spent_hours   => ( is=>"rw" ); 
has start_date    => ( is=>"rw" );
has status        => ( is=>"rw" );
has subject       => ( is=>"rw" );
has tracker       => ( is=>"rw" );
has updated_on    => ( is=>"rw" );


has watcher_user => ( is=>"rw" ); #- Array of user ids to add as watchers (since 2.3.0)

has json          => (is => "rw");


sub cache { 
    my ($self)=(@_);
    $self->connection->live_ticket_objects->{$self->id}=$self;
}

sub fetch_cache { 
    my ($self,%args)=@_;
    my $id=$args{id}; 	
    return undef unless $id;  
    my $connection=$args{connection}; 	
    return undef unless $connection;
    my $live=$connection->live_ticket_objects;
    return undef unless $live;
    return $live->{$id};
}


sub note {
   my ($self,$data)=@_;
   if ( defined($data) ) { 
      $self->notes($data);
   } else { 
      return $self->notes;
   } 
}

sub _build_created_at {
   my ($self)=@_;
   return DateTimeX::Easy->new($self->created_on) if ( $self->created_on);
}
sub _build_project {
   my ($self)=@_;
   if ( $self->connection->project ) {
       return Net::RedmineRest::Project->load(connection=>$self->connection, identifier=>$self->connection->project);
   }
}

sub _provide_update_data {
   my ($self,%args)=@_;
   my $content=$args{content};
   $content->{$self->entity}->{notes} = $self->notes() if ( defined($self->notes) );
   return $content;
}

sub _provide_data {

   my ($self)=@_;
   my $data={};  

    $data->{assigned_to_id}=$self->assigned_to->id if (defined($self->assigned_to) );
    $data->{category_id}=$self->category->id if (defined($self->category) );
    $data->{fixed_version_id}=$self->fixed_version->id if (defined($self->fixed_version) );
    $data->{is_private}=$self->is_private->id if (defined($self->is_private) );
    $data->{parent_issue_id}=$self->parent_issue->id if (defined($self->parent_issue) );
    $data->{project_id}=$self->project->id if (defined($self->project) );
    $data->{priority_id}=$self->priority->id if (defined($self->priority) );
    $data->{status_id}=$self->status->id if (defined($self->status) );
    $data->{tracker_id}=$self->tracker->id if (defined($self->tracker) );
    $data->{watcher_user_ids}=$self->watcher_user->ids if (defined($self->watcher_user) );

    $data->{description}=$self->description if (defined($self->description) );
    $data->{estimated_hours}=$self->estimated_hours if (defined($self->estimated_hours) );
    $data->{id}=$self->id if (defined($self->id) );
    $data->{subject}=$self->subject if (defined($self->subject) );

    my $content;

   $data=$self->clean_data($data);

   $content->{$self->entity}=$data;

   return $content;

}



sub refresh {

   my ($self,%args)=@_;
   my $json=$self->json;
   return unless ( $json );
   $self->created_on($json->{created_on});
   $self->updated_on($json->{updated_on});
   $self->description($json->{description});
   $self->subject($json->{subject});
   $self->start_date($json->{start_date});
   $self->due_date($json->{due_date});
   $self->done_ratio($json->{done_ratio});
   $self->estimated_hours($json->{estimated_hours});
   $self->spent_hours($json->{spent_hours});
   $self->id($json->{id});

   $self->notes($json->{notes});
   $self->project(
         Net::RedmineRest::Project->load(connection=>$self->connection, id=>$json->{project}->{id})
   );    
   $self->tracker(
         Net::RedmineRest::Simple->new(
             id=>$json->{tracker}->{id},
             name=>$json->{tracker}->{name}
         )
   ); 
   $self->status(
         Net::RedmineRest::Simple->new(
             id=>$json->{status}->{id},
             name=>$json->{status}->{name}
         )
   ); 
   $self->priority(
         Net::RedmineRest::Simple->new(
             id=>$json->{priority}->{id},
             name=>$json->{priority}->{name}
         )
   ); 
   $self->author(
         Net::RedmineRest::User->load(
             connection=>$self->connection,
             id=>$json->{author}->{id}
         )
   ); 
   $self->assigned_to(
         Net::RedmineRest::Simple->new(
             id=>$json->{assigned_to}->{id},
             name=>$json->{assigned_to}->{name}
         )
   ); 
   
}

sub _build_histories {
    my ($self) = @_;
    my $json=$self->json;

    return unless $json && $json->{journals} && ref($json->{journals}); 

    my @journals=@{$json->{journals}};
    my $n=scalar @journals;

    return [
        map {
            Net::RedmineRest::TicketHistory->new(
                connection=>$self->connection,
                id => $_,
                ticket=>$self
            )
        } (0..$n)
    ];
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::RedmineRest::Issue - Represents a issue.

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut
