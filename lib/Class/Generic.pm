package Class::Generic;

use Keyword::Declare;
use PPR;

use 5.008_005;
our $VERSION = '0.01';

our $DEFAULT_EXTENDS = 'extends';
our $RUBY_EXTENDS    = '>';
our $CUSTOM_EXTENDS  = '';

our @TRACE;

sub import {
    my $caller = caller();
    my $prefix = $caller || '';

    keytype RubyExtends   is '>';
    keytype PythonExtends is /[\w_]+\([\w_::]+\)/;

    keyword class (Bareword|PythonExtends $class, Bareword|RubyExtends? $extends, Bareword? $subclass, Block $block) {
        my @stack = ();

        if (my ($_class, $_subclass) = _python_extends($class)) {
            die "Unknown class and subclass from construct: $class"
                unless $_class and $_subclass;

            $class    = $_class    if $_class;
            $subclass = $_subclass if $_subclass;

            $extends = 'extends';
        }

        my $package = $prefix ? $prefix . '::' . $class : $class;

        # Don't inject initial use Moo here
        push @stack, <<MOO;
            use Moo;
            package $package {
                use Moo;
                use Method::Signatures;
MOO

        $block =~ s/^\{|\}$//g;

        push @stack, _trace();

        if ($subclass and $extends and _valid_extends($extends)) {
            push @stack, <<EXTENDS
                extends '$subclass';
EXTENDS
        }

        push @stack, "$block };";

        my $code = join '', @stack;
        push @TRACE, $code;

        return $code;
    };

    keyword attr (Bareword $name, Comma $c, Int|Str|AnonymousSubroutine|AnonymousHash|AnonymousArray|ScalarVar $attr) {
        my @stack = <<HAS;
            has $name => ( is => 'rw', default => 
HAS

        if ($attr =~ /^sub/) {
            push @stack, $attr;
        }
        else {
            push @stack, <<SUB
                sub { $attr }
SUB
        }

        push @stack, ");";

        my $code =  join '', @stack;
        push @TRACE, $code;

        return $code;
    }
}

sub _trace {
    my $src = '\(join "", @Class::Generic::TRACE)';

    return <<TRACE;
        method TRACE {
            my \$tidy   = eval { require Perl::Tidy };

            if (\$tidy) {
                Perl::Tidy::perltidy(
                    source => $src,
                );
            }
            else {
                return $src;
            }
        }
TRACE
}

sub _valid_extends {
    my $string = shift;

    return $string eq $DEFAULT_EXTENDS
        || $string eq $RUBY_EXTENDS
        || $string eq $CUSTOM_EXTENDS;
}

sub _python_extends {
    shift =~ /([\w_]+)\(([\w_::]+)\)/;
}

1;

__END__

=encoding utf-8

=head1 NAME

Class::Generic - Make generic classes in Perl

=head1 SYNOPSIS

    package MyPackage;

    use Mojo::UserAgent;
    use Class::Generic;

    class HTTP {
        attr user_agent => sub { Mojo::UserAgent->new };

        method fetch_link ($link) {
            $self->user_agent->get($link);
        }

        func say_hi {
            print "Say hi\n";
        }
    }

    # In another package...

    package MyOtherPackage;
    use MyPackage::HTTP;

    sub run {
        my $link = shift;

        my $http = MyPackage::HTTP->new;
        $http->fetch_link($link);
    }

=head1 DESCRIPTION

```Class::Generic``` declares new keywords using ```Keyword::Declare``` and injects ```Moo``` and ```Method::Signatures``` code into your package.

All class declarations use the parent package as a prefix for the scaffolded Moo package. In the example above:


    package MyPackage;

    use Class::Generic;


sets the package prefix as ```MyPackage```, so any class declaration afterwards are built as ```MyPackage::$class``` 

=head1 METHODS

```Class::Generic``` exports no functions nor methods. It simply parses your module's code and replaces it with ```Moo``` and ```use Method::Signatures``` code.

```Class::Generic``` looks for two keywords in your code: class and attr.

```class``` - looks for arguments in this order: name, extends, subclass, block. Extends and subclass are optional.

    class FooBar extends FooBaz {
        ...
    }

```attr``` - looks for a AnonymousHash, AnonymousArray, ScalarVar, or AnonymousSubroutine and generates a ```rw``` attribute (with no type checking).

    class Foobar {
        attr num        => 1;
        attr str        => 'hello world';
        attr user_agent => sub { Mojo::UserAgent->new };
    }

```method``` - From ```Method::Signatures``` 

```func``` - From ```Method::Signatures```

This will also inject a method  ```TRACE``` into your code so you can see the generated code:

    my $http = MyPackage::HTTP->new;
    $http->TRACE;

A global var $TRACE keeps track of all the code and passes a scalar ref to Perl::Tidy where it's beautified and printed to STDOUT.
For example, this code:

    package Test;
    use Class::Generic;

    class TestClass_05 {
        method say_hello {
            print "Hello\n";
        }

        func say_hi {
            print "Say hi\n";
        }
    }

    ... (In another file)

    use Test::TestClass_05;

    Test::TestClass_05->new->TRACE;

Prints:

    package Test_01::TestClass_05 {
        use Moo;
        use Method::Signatures;

        extends 'Exporter';

        method TRACE {
            my $tidy = eval { require Perl::Tidy };

            if ($tidy) {
                Perl::Tidy::perltidy(
                    source => \(join '', @Class::Generic::TRACE),
                );
            }
            else {
                return (join '', \@Class::Generic::TRACE);
            }
        }

        method say_hello {
            print "Hello\n";
        }

        func say_hi {
            print "Say hi\n";
        }
    };    

=head1 EXAMPLE

    package API;

    use Class::Generic;

    class Error extends Throwable {}

    class Client {
        use Try::Tiny;
        use API::Error;
        use Mojo::UserAgent;

        attr user_agent => sub { Mojo::UserAgent->new };

        method request_url($url) {
            my $resp;

            try {
                $resp = $self->user_agent->get($url);

                die $resp unless $resp->is_success;
            } catch {
                API::Error->throw({
                    message => "Failed to get url: $_"
                });
            };

            return $resp->content;
        }
    }

    class

=head1 WHY?

I was Inspired by Damian Conway's Dios, but I wanted a minimalistic approach to implementing classes in Perl, without using scary sigils
or Perl-specifc syntax (or what I like to refer to as "Python friendly").

=head1 AUTHOR

Connor Yates E<lt>cyates@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2017- Connor Yates

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
