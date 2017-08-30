package Test_01;

use lib 'lib';
use Class::Generic;

class TestClass_01 {
    method say_hello {
        print "Hello\n";
    }

    func say_hi {
        print "Say hi\n";
    }
};

class TestClass_02 extends Exporter {
    method say_hello {
        print "Hello\n";
    }

    func say_hi {
        print "Say hi\n";
    }
}

class TestClass_03 {
    attr str    => 'bar';
    attr num    => 1;
    attr zero   => 0;
    attr code   => sub { "DUMMY" };
    attr hash   => {};
    attr array  => [];
}

class TestClass_04 > Exporter {
    method say_hello {
        print "Hello\n";
    }

    func say_hi {
        print "Say hi\n";
    }
}

class TestClass_05(Exporter) {
    method say_hello {
        print "Hello\n";
    }

    func say_hi {
        print "Say hi\n";
    }
}

1;


