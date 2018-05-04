package BlockchainNode::Constants;

use warnings;
use strict;
use Exporter 'import';

use constant MINING_SENDER => "THE BLOCKCHAIN";
use constant MINING_REWARD => 1;
use constant MINING_DIFFICULTY => 2;

our @EXPORT_OK = (qw/MINING_SENDER MINING_REWARD MINING_DIFFICULTY/);
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

1;

