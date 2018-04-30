use warnings;
use strict;

package BlockchainNode::Server;

use BlockchainNode;
use Plack::Runner;

sub run {
  Plack::Runner->run(@_, BlockchainNode->to_app);
}

return caller(1) ? 1 : run(@ARGV);

=head1 TITLE

BlockchainNode::Server - Start the application under a web server

=head1 DESCRIPTION

Start the web application.  Example:

    perl -Ilib  lib/BlockchainNode/Server.pm --server Gazelle

=head1 AUTHORS & COPYRIGHT

See L<BlockchainNode>.

=head1 LICENSE

See L<BlockchainNode>.

=cut
