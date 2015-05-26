package Net::Redmine::Simple;
use Moo;
use Net::Redmine::Base;
extends 'Net::Redmine::Base';

has name => ( is=>"rw" );
has id => ( is=>"rw" );
has connection => ( is=>"rw" );

sub _provide_data {

   my ($self)=@_;
   my $data;  
   $data->{name}=$self->name if (defined($self->name) );
   $data->{id}=$self->id if (defined($self->id) );
   my $content;
   $content->{$self->entity}=$data;
   return $content;

}

sub load {
}

sub refresh_from_json {

   my ($self,%args)=@_;
   my $json=$self->json;
   if ( $json ) {
      $self->name($json->{name});
      $self->id($json->{id});
   } 
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Redmine::Issue - Represents a issue.

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut