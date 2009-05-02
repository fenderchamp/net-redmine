package Net::Redmine;
use Any::Moose;
our $VERSION = '0.02';
use Net::Redmine::Connection;
use Net::Redmine::Ticket;

has connection => (
    is => "ro",
    isa => "Net::Redmine::Connection",
    required => 1
);

sub BUILDARGS {
    my $class = shift;
    my %args = @_;

    $args{connection} = Net::Redmine::Connection->new(
        url      => delete $args{url},
        user     => delete $args{user},
        password => delete $args{password}
    );

    return $class->SUPER::BUILDARGS(%args);
}

sub create {
    my ($self, %args) = @_;
    return $self->create_ticket(%$_) if $_ = $args{ticket};
}

sub create_ticket {
    my ($self, %args) = @_;
    my $t = Net::Redmine::Ticket->new(connection => $self->connection);
    $t->create(%args);
    return $t;
}

1;
__END__

=head1 NAME

Net::Redmine - A mechanized-based programming API against redmine server.

=head1 SYNOPSIS

  use Net::Redmine;

=head1 DESCRIPTION

Net::Redmine is an mechanized-based programming API against redmine server.

=head1 AUTHOR

Kang-min Liu E<lt>gugod@gugod.orgE<gt>

=head1 SEE ALSO

L<http://redmine.org>, L<Net::Trac>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009, Kang-min Liu C<< <gugod@gugod.org> >>.

This is free software, licensed under:

    The MIT (X11) License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
