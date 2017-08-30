# NAME

Class::Generic - Make generic classes in Perl

# SYNOPSIS

```perl
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
```

# DESCRIPTION

```Class::Generic``` declares new keywords using ```Keyword::Declare``` and injects ```Moo``` and ```Method::Signatures``` code into your package.

All class declarations use the parent package as a prefix for the scaffolded Moo package. In the example above:

```perl
    package MyPackage;

    use Class::Generic;
```

sets the package prefix as ```MyPackage```, so any class declaration afterwards are built as ```MyPackage::$class``` 

# METHODS

```Class::Generic``` exports 1 method, ```TRACE``` (more on this later). It simply parses your module's code and replaces it with ```Moo``` and ```use Method::Signatures``` code.

```Class::Generic``` looks for two keywords in your code: class and attr.

```class``` - looks for arguments in this order: name, extends, subclass, block. Extends and subclass are optional.

```perl
    class FooBar extends FooBaz {
        ...
    }
```

```attr``` - looks for a AnonymousHash, AnonymousArray, ScalarVar, or AnonymousSubroutine and generates a ```rw``` attribute (with no type checking).

    class Foobar {
        attr num        => 1;
        attr str        => 'hello world';
        attr user_agent => sub { Mojo::UserAgent->new };
    }

```method``` - From ```Method::Signatures``` 

```func``` - From ```Method::Signatures```

This will also inject a method  ```TRACE``` into your code so you can see the generated code:

```perl
    my $http = MyPackage::HTTP->new;
    $http->TRACE;
```

A global var ```$TRACE``` keeps track of all the code and passes a scalar ref to ```Perl::Tidy``` where it's beautified and printed to ```STDOUT```.
For example, this code:

```perl
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
```

Prints:

```
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
```

# EXAMPLE

```perl
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
```

# WHY?

I was Inspired by Damian Conway's [Dios](https://metacpan.org/pod/Dios), but I wanted a minimalistic approach to implementing classes in Perl, without using scary sigils
or Perl-specifc syntax (or what I like to refer to as "Python friendly").

# AUTHOR

Connor Yates ```cyates@cpan.org```

# COPYRIGHT

Copyright 2017- Connor Yates

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

