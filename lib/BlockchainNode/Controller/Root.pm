package BlockchainNode::Controller::Root;

use BlockchainNode::Controller;

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

__PACKAGE__->meta->make_immutable;
