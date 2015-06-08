use inc::Module::Install;
name 'Net-Redmine';
all_from 'lib/Net/Redmine.pm';

requires
    "REST::Client"                  => "1",
    #"DateTime::Format::DateParse"   => "0.04",
    #"DateTimeX::Easy"               => "0.086",
    #"Encode"                        => "2.31",
    #"HTML::WikiConverter"           => "0.68",
    #"HTML::WikiConverter::Markdown" => "0.05",
    #"JSON"                          => "2.90",
    #"IO::All"                       => "0.39",
    #"WWW::Mechanize"                => "1.52",
    #"IO::String"                    => "1.08",
    #"Moo"                           => "2.000001",
    #"Params::Validate"              => "0.91",
    #"pQuery"                        => "0.07";
    #"Regexp::Common"                => "2.122",
    #"Regexp::Common::Email::Address" => "1.01",
    #"Text::CSV::Slurp"              => "0.5",
    #"URI"                           => "1.38",
    #"URI::Escape"                   => "3.29",

build_requires
    "Test::Cukes"             => "0.06",
    "Test::Memory::Cycle"     => "1.04",
    "Text::Greeking"          => "0.11",
    "Quantum::Superpositions" => "1.03",
    "Test::More"              => "0.86";

repository 'http://github.com/gugod/net-redmine';

tests 't/*.t';
author_tests 'xt';

auto_include;
# auto_license;
WriteAll;
