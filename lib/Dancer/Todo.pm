package Dancer::Todo;
use Dancer2;
use Dancer2::Plugin::RootURIFor;
use Dancer2::Plugin::DBIC;
use base qw(DBIx::Class::Schema::Loader);
use Template;
our $VERSION = '0.1';

get '/' => sub {
    my $todo_schema = DBIx::Class::Schema::Loader->connect('dbi:SQLite:dbname=todos.db');    
    my @todos = $todo_schema->resultset('Todos')->search({});
    template 'index', { results => \@todos, title => 'Pending Todos' };
    
};

get '/add' => sub {
    template 'add', {title => 'Add Todo'};
};

post '/add' => sub {

    my $title = body_parameters->get('title');
    my $todo_schema = DBIx::Class::Schema::Loader->connect('dbi:SQLite:dbname=todos.db');    
    $todo_schema->populate('Todos', 
        [
            [ 'title' ],
            [$title], 
        ]
    );
    redirect "/";
};

get '/delete/:id' => sub {
    my $id = param('id');

    my $todo_schema = DBIx::Class::Schema::Loader->connect('dbi:SQLite:dbname=todos.db');    
    my $todos = $todo_schema->resultset('Todos')->search({ 'id' => $id });
    $todos->delete;

    redirect "/";
};

get '/update/:id' => sub {
    my $id = param('id');

    my $todo_schema = DBIx::Class::Schema::Loader->connect('dbi:SQLite:dbname=todos.db');    
    my $todo = $todo_schema->resultset('Todos')->find({ 'id' => $id });
    template 'update', { title => "Update Todo", todo_title => $todo->title, id => $todo->id, status => $todo->status };
};


post '/update/:id' => sub {
    my $title = body_parameters->get('title');
    my $id = body_parameters->get('id');
    my $status = body_parameters->get('status');

    my $updated_status;
    if($status) {
        $updated_status = 1;
    } else {
        $updated_status = 0;
    }
        

    my $todo_schema = DBIx::Class::Schema::Loader->connect('dbi:SQLite:dbname=todos.db');    
    my $todo = $todo_schema->resultset('Todos')->search({ 'id' => $id });
    $todo->update({title => $title, status => $updated_status});
    redirect "/";

};

true;

