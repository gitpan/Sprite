use ExtUtils::MakeMaker;
require 5.002;

$VERSION = "3.1";

print "\nWelcome to the installation of Sprite $VERSION...\n\n";

WriteMakefile (
                 NAME      =>   "Sprite",
                 DISTNAME  =>   "Sprite",
                 MAN3PODS  =>   ' ',  
                 VERSION   =>   "$VERSION",
                 'dist'    =>   {COMPRESS=>'gzip -9f', SUFFIX => 'gz'}
              );

print <<End_of_Text;

Now do the following to install Sprite:

    % make 
    % make install

End_of_Text
