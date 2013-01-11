Psych Shield
============

Psych Shield provides a way to filter objects during a YAML.load call
when the Psych parser is used (default in Ruby 1.9). This can prevent
malicious input to a YAML.load call from resulting in bad things within
your application.

This is a dirty hack that allows applications that need to accept
untrusted YAML input to continue doing so until they can be ported
to a new format.


To protect a Ruby on Rails application, add the following to Gemfile:

    gem 'psych_shield'

Rails 2 applications should add an initializer that loads this gem.

    $ echo 'require "psych_shield"' > config/initializers/load_psych_shield.rb

By default, Psych Shield allows the following types of objects:

    Hash Array String Range
    Numeric Fixnum Integer Bignum Float Rational Complex
    Time DateTime
    NilClass TrueClass FalseClass

To enable additional classes, add the stringified form using the "add" method:

    PsychShield.add('MyClass::IsAwesome::And::Safe')

To disable all classes (even the defaults), use the clear method:

    PsychShield.clear

To figure out what classes you need to allow, you can use the callback:

    PsychShield.callback = Proc.new { |klass,result|
        $stderr.puts "#{ result ? "Allowed" : "Denied"} class #{klass}"
    }

Denied objects are removed from the resulting ruby implementation


PsychShield passes all expected psych tests included in the Ruby source:

    $ ruby -I lib/ -r psych_shield -I /usr/local/rvm/src/ruby-1.9.3-p194/test/ /usr/local/rvm/src/ruby-1.9.3-p194/test/psych/test_psych.rb
    Run options: --seed 61780

    # Running tests:

    ................F.....

    Finished tests in 0.011105s, 1981.1699 tests/s, 3331.9675 assertions/s.

    1) Failure:
    test_non_existing_class_on_deserialize(TestPsych) [/usr/local/rvm/src/ruby-1.9.3-p194/test/psych/test_psych.rb:53]:
    ArgumentError expected but nothing was raised.

    22 tests, 37 assertions, 1 failures, 0 errors, 0 skips


The YAML test has one failure, as is expected (Struct::MyBookStruct was filtered):

    $ ruby -I lib/ -r psych_shield -I /usr/local/rvm/src/ruby-1.9.3-p194/test/ /usr/local/rvm/src/ruby-1.9.3-p194/test/psych/test_yaml.rb
    Run options: --seed 31567

    # Running tests:

    ...........F.................................................

    Finished tests in 0.200379s, 304.4230 tests/s, 1282.5688 assertions/s.

    1) Failure:
    test_ruby_struct(Psych_Unit_Tests) [/usr/local/rvm/src/ruby-1.9.3-p194/test/psych/test_yaml.rb:1039]:
    --- expected
    +++ actual
    @@ -1 +1 @@
    -[#<struct Struct::MyBookStruct author="Yukihiro Matsumoto", title="Ruby in a Nutshell", year=2002, isbn="0-596-00214-9">, #<struct Struct::MyBookStruct author=["Dave Thomas", "Andy Hunt"],     title="The     Pickaxe", year=2002, isbn=#<struct Struct::MyBookStruct author="This should be the ISBN", title="but I have another struct here", year=2002, isbn="None">>]
    +[#<struct author="Yukihiro Matsumoto", title="Ruby in a Nutshell", year=2002, isbn="0-596-00214-9">, #<struct author=["Dave Thomas", "Andy Hunt"], title="The Pickaxe", year=2002, isbn=#<struct     author="This should be the ISBN", title="but I have another struct here", year=2002, isbn="None">>]


    61 tests, 257 assertions, 1 failures, 0 errors, 0 skips
