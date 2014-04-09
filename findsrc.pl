#!
# suppresses output files (html from xhtml)
open filelist,"find . -regex '.*\\.x?html[^~]*\$' |";
while(<filelist>){
    chop;
    if(/^(.+).xhtml(\..+)$/){
	$out = "$1.html$2";
	$output{"$out"} = "1";
	$hasoutput{"$_"} = "1";
    }
    push @files, $_;
    $all{"$_"}="1";
    $all{"$out"}="1";
}
close filelist;
if($ARGV[0] eq 'src'){
# src -- outputs source xhtml/html files
    foreach $vval (@files){
	if(!$output{$vval}){
	    print "$vval\n";
	}
    }
}
elsif($ARGV[0] eq 'bld') {
# bld -- outputs target (to be build from xhtml) html files
    foreach $vval (keys %output){
	if($output{$vval}){
	    print "$vval\n";
	}
    }
}
else {
# out -- outputs final file list (omits source xhtml files)
    foreach $vval (sort keys %all){
	if(!$hasoutput{$vval}){
	    print "$vval\n";
	}
    }
}

