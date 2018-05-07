package BlockchainNode::Blockchain;

use signatures;
use JSON::MaybeXS;
use Crypt::Misc 'random_v4uuid';
use Crypt::Digest::SHA256 'sha256_hex';
use Crypt::Digest::SHA1 'sha1';
use URL::URI;
use BlockchainNode::Constants ':all';
use Data::Dumper;
use Moose;

has 'transactions' =>  (
  traits  => ['Array'],
  is=>'ro',
  required=>1,
  default=>sub { [] }
  handles => +{
    transactions_clear => 'clear',
    transactions_append => 'add',
  },
);

has 'nodes' =>  (
  traits  => ['Array'],
  is=>'ro',
  required=>1,
  default=>sub { [] }
  handles => +{
    nodes_append => 'add'
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
    chain_length => 'count'
    chain_append => 'add',
    chain_get => 'get',
  },
);

  sub chain_last { shift->chain_get(-1) }
  *last_block \&chain_last; # alias for clarity

sub create_block($self, $nounce, $previous_hash) {
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
  my $parsed_url = URI::URL->new($node_url);
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
  while($self->valid_proof($self->transactions, $last_hash, $nonce)) ) {
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


__PACKAGE__->meta->make_immutable;

__END__

    def valid_chain(self, chain):
        """
        check if a bockchain is valid
        """
        last_block = chain[0]
        current_index = 1

        while current_index < len(chain):
            block = chain[current_index]
            #print(last_block)
            #print(block)
            #print("\n-----------\n")
            # Check that the hash of the block is correct
            if block['previous_hash'] != self.hash(last_block):
                return False

            # Check that the Proof of Work is correct
            #Delete the reward transaction
            transactions = block['transactions'][:-1]
            # Need to make sure that the dictionary is ordered. Otherwise we'll get a different hash
            transaction_elements = ['sender_address', 'recipient_address', 'value']
            transactions = [OrderedDict((k, transaction[k]) for k in transaction_elements) for transaction in transactions]

            if not self.valid_proof(transactions, block['previous_hash'], block['nonce'], MINING_DIFFICULTY):
                return False

            last_block = block
            current_index += 1

        return True

    def resolve_conflicts(self):
        """
        Resolve conflicts between blockchain's nodes
        by replacing our chain with the longest one in the network.
        """
        neighbours = self.nodes
        new_chain = None

        # We're only looking for chains longer than ours
        max_length = len(self.chain)

        # Grab and verify the chains from all the nodes in our network
        for node in neighbours:
            print('http://' + node + '/chain')
            response = requests.get('http://' + node + '/chain')

            if response.status_code == 200:
                length = response.json()['length']
                chain = response.json()['chain']

                # Check if the length is longer and the chain is valid
                if length > max_length and self.valid_chain(chain):
                    max_length = length
                    new_chain = chain

        # Replace our chain if we discovered a new, valid chain longer than ours
        if new_chain:
            self.chain = new_chain
            return True

        return False


1;
