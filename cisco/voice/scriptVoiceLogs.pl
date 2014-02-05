#!/usr/bin/perl

if ($#ARGV != 0) {
    print "Usage : ./scriptVoiceLogs.pl nomdufichierdelogs";
    exit;
}

open(FILE,"<$ARGV[0]");
@voice=<FILE>;

$history=@voice;

@connecttimes=();
@connectionids=();
@disconnectcauses=();
@disconnecttexts=();



foreach $i (0..$history) {
    #
    if ($voice[$i] =~ /%VOIPAAA-5-VOIP_CALL_HISTORY:/) {
        #print $voice[$i];
        @infos = split(/,/, $voice[$i]);
        $disconnect_cause = $infos[5];
        ($code) = ($disconnect_cause =~ /DisconnectCause (\w+)/);
        if ($code ne '' && $code ne '10') {
            #print $infos[1];ConnectionId
            ($connecttime) = ($infos[7] =~ /ConnectTime \.(.+)/);
            ($connectionid) = ($infos[1] =~ /ConnectionId (\w+)/);
            #print $connecttime." ".$connectionid." DisconnectCause : ".$code." -";
            ($disconnecttext) = ($infos[6] =~ /DisconnectText (.+)/);
            #print $disconnecttext."\n";
            push(@connecttimes,$connecttime);
            push(@connectionids,$connectionid);
            push(@disconnectcauses,$disconnect_cause);
            push(@disconnecttexts,$disconnecttext);          
        }
    }
}

foreach $id (0..@connectionids) {
    foreach $i (0..$history) {
        if ($voice[$i] =~ /%VOIPAAA-5-VOIP_FEAT_HISTORY:/) {
            if ($voice[$i] =~ /fcid:$connectionids[$id]/) {    
                ($cgn) = ($voice[$i] =~ /cgn:(\d+),/);
                ($cdn) = ($voice[$i] =~ /cdn:(\d+),/);
                ($time) = ($voice[$i] =~ /ft:(\d{2}\/\d{2}\/\d{4} \d\d:\d\d)/);
                print $time.",".$cgn.",".$cdn.",".$disconnecttexts[$id]."\n";
                last;
            }
        }
    }        
}
