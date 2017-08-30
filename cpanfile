requires 'perl', '5.008005';

requires 'Keyword::Declare', '0.001006'; 
requires 'Moo', '2.003002';
requires 'Method::Signatures', '20170211';

on test => sub {
    requires 'Test::More', '0.96';
};
