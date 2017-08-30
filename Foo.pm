package API;
use Class::Generic;

class Client {
    use LWP::UserAgent;

    attr user_agent => sub { LWP::UserAgent->new };

    method fetch_link($url) {
        my $resp = $self->user_agent->get($url);
        return $resp->content;
    }
}

class Plugin {
    use Dancer::Plugin;
    use API::Client;
    use API::Model;

    plugin client_manager => sub { API::Client->new };
    plugin db_manager     => sub { API::Model->new  };

    register_plugin;
}

class Model {
    use DBI;
    use DBD::mysql;

    our $db;

    attr db => sub { $db ||= DBI->connect(); $db->dbh };

    method log_resp($content, $module) {
        my $dbh = $self->db->dbh;
        my $sql = qq{INSERT INTO cpan(name = $module, content = $content)};
        my $sth = $dbh->prepare($sql);
        return $sth->execute;
    }
}

class Server {
    use API::Plugin;
    use Dancer ':syntax';

    set serializer => 'JSON';

    any '/' => sub { +{ message => 'Hello, world!' } };

    post '/search/:keyword' => sub {
        my $keyword = param 'keyword';
        my $url     = "https://metacpan.org/search?q=$keyword";
        my $content = plugin_manager()->fetch_link($url);

        db_manager()->log_resp($content, $module);

        return { message => $content };
    };
}
