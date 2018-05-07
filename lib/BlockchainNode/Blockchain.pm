package BlockchainNode::Blockchain;

use signatures;
use JSON::MaybeXS;
use Crypt::Misc 'random_v4uuid';
use Crypt::Digest::SHA256 'sha256_hex';
use Crypt::Digest::SHA1 'sha1';
use URI;
use BlockchainNode::Constants ':all';
use Data::Dumper;
use HTTP::Tiny;
use Moose;

has 'transactions' =>  (
  traits  => ['Array'],
  is=>'ro',
  required=>1,
  default=>sub { [] },
  handles => +{
    transactions_clear => 'clear',
    transactions_append => 'push',
  },
);

has 'nodes' =>  (
  traits  => ['Array'],
  is=>'ro',
  required=>1,
  default=>sub { [] },
  handles => +{
    nodes_append => 'push'
  },
);

has 'node_id' =>  (
  is => 'ro',
  required => 1,
  default => sub {
    (my $uuid = random_v4uuid) =~s/-//g;
    return $uuid;
  }
);

has 'chain' => (
  traits  => ['Array'],
  is => 'ro',
  required => 1,
  lazy => 1,
  default=>sub { shift->create_block(0, '00') },
  handles => +{
    chain_length => 'count',
    chain_append => 'push',
    chain_get => 'get',
  },
);

sub chain_last { return shift->chain_get(-1) }

sub create_block($self, $nonce, $previous_hash) {
  my $block = +{
    block_number => $self->chain_length,
    timestamp => time,
    transactions => $self->transactions,
    nonce => $nonce,
    previous_hash => $previous_hash}; # Should this be ordered hash...?

  $self->transactions_clear;
  $self->chain_append($block);

  return $block;
}

# This creates a JSON encoder that forces keys to be
# alphabetically ordered.  Necessary because for the hashes
# to be correct the underlying string can't change.
my $JSON = JSON::MaybeXS->new(utf8 => 1, canonical=>1);

sub hash($self, $block) {
  # Create a SHA-256 hash of a block
  my $block_string = $JSON->encode($block);
  return sha256_hex($block_string);

}

sub register_node($self, $node_url) {
  # Add a new node to the list of nodes
  # I'm going to be more strict than the python version, and do
  # sanity checking on the Catalyst side.
  my $parsed_url = URI->new($node_url);
  my $host = $parsed_url->can('host') ?
    $parsed_url->host :
      die 'Invalid URL';
  $self->nodes_append($host);
}

sub verify_transaction_signature($self, $sender_address, $signature, $transaction) {
  my $sender_public_key = decode_b32b($sender_address);
  my $public_key = Crypt::PK::RSA->new(\$sender_public_key);
  my $message = sha1(Dumper @{$transaction}); # Need to take care about not using a Hash
  return $public_key->verify_message(decode_b32b($signature), $message)
}

sub submit_transaction($self, %t) {
  # Please note this returns an arrayref because Perl hashes are not
  # going to preserve key order.
  my $transaction = [
    sender_address => $t{sender_address}, 
    recipient_address => $t{recipient_address}, 
    value => $t{value}, 
    signature => $t{signature},
  ];

  if($t{sender_address} eq MINING_SENDER) {
    $self->transactions_append($transaction);
    return $self->chain_length +1;
  } else {
    my $transaction_verification = $self->verify_transaction_signature($t{sender_address}, $t{signature}, $t{transaction});
    if($transaction_verification) {
      $self->transactions_append($transaction);
      return $self->chain_length +1;
    } else {
      return undef;
    }
  }
}

sub proof_of_work($self) {
  my $last_block = $self->chain_last;
  my $last_hash = $self->hash($last_block);
  my $nonce = 0;
  while($self->valid_proof($self->transactions, $last_hash, $nonce)) {
    $nonce += 1;
  }
  return $nonce;
}

sub valid_proof($self, $transactions, $last_hash, $nonce, $difficulty) {
  $difficulty = MINING_DIFFICULTY unless $difficulty;
  my $guess = (Dumper($transactions)+Dumper($last_hash)+Dumper($nonce));
  my $guess_hash = sha256_hex($guess);
  return substr($guess_hash, 0, $difficulty) eq ('0'x$difficulty) ? 1:0;
}

sub valid_chain($self, $chain) {
  my $last_block = $chain->[0];
  my $current_index = 1;
  while($current_index < scalar(@{$chain})) {
    my $block = $chain->[$current_index]; # ??? Can this be right ???
    if($block->{previous_hash} ne $self->hash($last_block)) {
      return undef;
    }
    my @transactions = @{$block->{transactions}};
    pop @transactions;

    @transactions = map { [
      sender_address => $_->{sender_address},
      recipient_address => $_->{recipient_address},
      value => $_->{value},
    ] } @transactions;

    return undef unless $self->valid_proof(
      \@transactions,
      $block->{previous_hash},
      $block->{nonce},
      MINING_DIFFICULTY);

    $last_block = $block;
    $current_index++;
  }
  return 1;
}

sub resolve_conflicts($self) {
  my $neighbours = $self->nodes;
  my $new_chain;
  my $max_length = $self->chain_length;

  for my $node(@$neighbours) {
    my $response = HTTP::Tiny->new->get("http://$node/chain");
    if($response->{success}) {
      my $json = $JSON->decode($response->{content});
      my $length = $json->{length};
      my $chain = $json->{chain};
      if( ($length > $max_length) and ($self->valid_chain($chain)) ) {
        $new_chain = $chain;
        $max_length = $length;
      }
    }
  }

  if($new_chain) {
    $self->chain($new_chain);
    return 1;
  }
  return undef;
}

__PACKAGE__->meta->make_immutable;
