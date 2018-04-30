use warnings;
use strict;

package BlockchainClient::Server;

use BlockchainClient;
use Plack::Runner;

sub run {
  Plack::Runner->run(@_, BlockchainClient->to_app);
}

return caller(1) ? 1 : run(@ARGV);

=head1 TITLE

BlockchainClient::Server - Start the application under a web server

=head1 DESCRIPTION

Start the web application.  Example:

    perl -Ilib  lib/BlockchainClient/Server.pm --server Gazelle

=head1 AUTHORS & COPYRIGHT

See L<BlockchainClient>.

=head1 LICENSE

See L<BlockchainClient>.

=cut
