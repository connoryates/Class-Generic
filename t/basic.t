use strict;
use Test::More;
use lib 't/modules';
use Test_01;

subtest 'Creating modules' => sub {
    my $t0 = Test_01->new;

    isa_ok $t0, 'Test_01';

    my $t1 = Test_01::TestClass_01->new;

    isa_ok $t1, 'Test_01::TestClass_01';

    my $t2 = Test_01::TestClass_02->new;

    isa_ok $t2, 'Test_01::TestClass_02';
    isa_ok $t2, 'Exporter';

    my $t3 = Test_01::TestClass_03->new;
    isa_ok $t3, 'Test_01::TestClass_03';

    is $t3->str, 'bar';
    is $t3->num, 1;
    is $t3->zero, 0;
    is $t3->code, 'DUMMY';

    isa_ok $t3->hash, 'HASH';
    isa_ok $t3->array, 'ARRAY';

    my $t4 = Test_01::TestClass_04->new;

    isa_ok $t4, 'Test_01::TestClass_04';
    isa_ok $t4, 'Exporter';

    my $t5 = Test_01::TestClass_05->new;

    isa_ok $t5, 'Test_01::TestClass_05';
    isa_ok $t5, 'Exporter';

    $t5->TRACE;
};

done_testing();
