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

__PACKAGE__->meta->make_immutable;
