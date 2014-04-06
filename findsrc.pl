#!
# suppresses output files (html from xhtml)
open filelist,"find . -regex '.*\\.x?html[^~]*\$' |";
while(<filelist>){
    chop;
    if(/(.+).xhtml(\..+)/){
	$out = "$1.html$2";
	$output{"$out"} = "1";
    }
    push @files, $_;
}
close filelist;
if($ARGV[0] eq 'src'){
    foreach $vval (@files){
	if(!$output{$vval}){
	    print "$vval\n";
	}
    }
}
else {
    foreach $vval (@files){
	if($output{$vval}){
	    print "$vval\n";
	}
    }
}

