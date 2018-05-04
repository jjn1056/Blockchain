package BlockchainNode::Controller::Root;

use BlockchainNode::Controller;
use BlockchainNode::Constants ':all';

sub index($self, $c) :  At(/) {
  $c->serve_file('node/index.html');
}

sub configure($self, $c) : At('/configure') {
  $c->serve_file('node/configure.html');
}

sub static($self, $c, @args) : At('/static/{*}') {
  $c->serve_file('static', @args) || do {
    $c->res->status(404);
    $c->res->body('Not Found') };
}

sub new_transaction($self, $c) : POST At('/transactions/new') {
  my $form = $_->model('Form::Transaction');
  if($form->validated) {
    if(my $result = $c->model('Blockchain')->submit_transaction(%{$form->fif})) {
      return $c->view('TransactionAdded', transaction_result=>$result)->http_201;
    } else {
      return $c->view('InvalidTransaction')->http_406;
    }
  } else {
    # TODO this should return the form validation errors instead
    $c->res->status(400);
    $c->res->body('Missing values');
  }
}

sub get_transactions($self, $c) : GET At('/transactions/get') {
  my $transactions = $c->model('Blockchain')->transactions;
  return $c->view('Transactions', transactions=>$transactions)
    ->http_200
}

sub full_chain($self, $c) : GET At('/chain') {
  my $blockchain = $c->model('Blockchain')->chain;
  return $c->view('Chain',
    chain => $blockchain->chain,
    length => $blockchain->chain_length,
  )->http_200;
}

sub get_nodes($self, $c) : GET At('/nodes/get') {
    my $nodes = $self->model('Blockchain')->nodes;
    return $c->view('Nodes', nodes=>$nodes)
      ->http_200;
}

sub consensus($self, $c) : GET At(''/nodes/resolve'') {
  my $blockchain = $c->model('Blockchain');
  my $replaced = $blockchain->resolve_conflicts;
  if($replaces) {
    $c->view('ConflictResolution',
      'message' => 'Our chain was replaced',
      'new_chain': $blockchain->chain,
    )->http_200;
  } else {
    $c->view('ConflictResolution',
      'message' => 'Our chain is authoritative',
      'new_chain': $blockchain->chain,
    )->http_200;
  }
}

__PACKAGE__->meta->make_immutable;

__END__

@app.route('/mine', methods=['GET'])
def mine():
    # We run the proof of work algorithm to get the next proof...
    last_block = blockchain.chain[-1]
    nonce = blockchain.proof_of_work()

    # We must receive a reward for finding the proof.
    blockchain.submit_transaction(sender_address=MINING_SENDER, recipient_address=blockchain.node_id, value=MINING_REWARD, signature="")

    # Forge the new Block by adding it to the chain
    previous_hash = blockchain.hash(last_block)
    block = blockchain.create_block(nonce, previous_hash)

    response = {
        'message': "New Block Forged",
        'block_number': block['block_number'],
        'transactions': block['transactions'],
        'nonce': block['nonce'],
        'previous_hash': block['previous_hash'],
    }
    return jsonify(response), 200

@app.route('/nodes/register', methods=['POST'])
def register_nodes():
    values = request.form
    nodes = values.get('nodes').replace(" ", "").split(',')

    if nodes is None:
        return "Error: Please supply a valid list of nodes", 400

    for node in nodes:
        blockchain.register_node(node)

    response = {
        'message': 'New nodes have been added',
        'total_nodes': [node for node in blockchain.nodes],
    }
    return jsonify(response), 201
