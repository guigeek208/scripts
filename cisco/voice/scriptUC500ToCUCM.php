<?php
/*MAC ADDRESS,DESCRIPTION,LOCATION,DIRECTORY NUMBER 1,DISPLAY 1,LINE TEXT LABEL 1,FORWARD BUSY EXTERNAL DESTINATION 1, FORWARD BUSY INTERNAL DESTINATION 1,FORWARD NO ANSWER INTERNAL DESTINATION 1,FORWARD NO ANSWER EXTERNAL DESTINATION 1,FORWARD NO COVERAGE EXTERNAL DESTINATION 1,FORWARD NO COVERAGE INTERNAL DESTINATION 1,CALL PICKUP GROUP 1*/

/*MAC ADDRESS,DESCRIPTION,DIRECTORY NUMBER 1,DISPLAY 1,LINE TEXT LABEL 1,FORWARD BUSY EXTERNAL DESTINATION 1, FORWARD BUSY INTERNAL DESTINATION 1,FORWARD NO ANSWER INTERNAL DESTINATION 1,FORWARD NO ANSWER EXTERNAL DESTINATION 1,FORWARD NO COVERAGE EXTERNAL DESTINATION 1,FORWARD NO COVERAGE INTERNAL DESTINATION 1,CALL PICKUP GROUP 1*/

function parsePHONE($handle, $listDN) {
    $phones = array();
    if ($handle) {
        $i=1;
        while (($line = fgets($handle)) !== false) {
            preg_match_all("/ephone\s+(.*)/", $line, $matches, PREG_SET_ORDER);
            if (count($matches) > 0) {
                $line2 = $line;
                while (!preg_match_all("/\s*!\s*/", $line2, $matches, PREG_SET_ORDER)) {
                    $line2 = fgets($handle);
                    //echo $line2;
                    preg_match_all("/\s+mac-address\s+([0-9A-F]{4})\.([0-9A-F]{4})\.([0-9A-F]{4})/", $line2, $matches, PREG_SET_ORDER);
                    if (count($matches) > 0) {
                        $macaddress = $matches[0][1].$matches[0][2].$matches[0][3];
                    }
                    preg_match_all("/\s+type\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                    if (count($matches) > 0) {
                        $type = $matches[0][1];
                    }
                    preg_match_all("/\s+button\s+(.*)\n/", $line2, $matches, PREG_SET_ORDER);
                    if (count($matches) > 0) {
                        preg_match_all("/(\d+):(\d+)/",$matches[0][1], $matches2, PREG_SET_ORDER);
                        if (count($matches2) > 0) {
                            if ($matches2[0][1] == "1") {
                                $dn = $matches2[0][2];
                                $csv = $macaddress;
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['name']) ? $listDN[$dn]['name'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['number']) ? $listDN[$dn]['number'] : "";
                                $csv .=  ",";
                                $csv .= isset($listDN[$dn]['name']) ? $listDN[$dn]['name'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['name']) ? $listDN[$dn]['name'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['busy']) ? $listDN[$dn]['busy'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['busy']) ? $listDN[$dn]['busy'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['cfnoan']) ? $listDN[$dn]['cfnoan'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['cfnoan']) ? $listDN[$dn]['cfnoan'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['cfnoan']) ? $listDN[$dn]['cfnoan'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['cfnoan']) ? $listDN[$dn]['cfnoan'] : "";
                                $csv .= ",";
                                $csv .= isset($listDN[$dn]['pickup-group']) ? $listDN[$dn]['pickup-group'] : "";
                                $phones[$type][] = $csv;
                                //echo $type." ";
                                //echo $csv."\n";
                            }
                        }
                    }
                }
            }   
            $i++;
        }
    } else {
        // error opening the file.
    }
    
    
    foreach ($phones as $key => $value) {
        $fp = fopen($key.".csv", 'w');
        fwrite($fp, "MAC ADDRESS,DESCRIPTION,DIRECTORY NUMBER 1,DISPLAY 1,LINE TEXT LABEL 1,FORWARD BUSY EXTERNAL DESTINATION 1, FORWARD BUSY INTERNAL DESTINATION 1,FORWARD NO ANSWER INTERNAL DESTINATION 1,FORWARD NO ANSWER EXTERNAL DESTINATION 1,FORWARD NO COVERAGE EXTERNAL DESTINATION 1,FORWARD NO COVERAGE INTERNAL DESTINATION 1,CALL PICKUP GROUP 1\n");
        foreach($value as $phone) {
            fwrite($fp, $phone);
            fwrite($fp, "\n");
        }
        fclose($fp);
    }
}

function parseDN($handle) {
    $listDN = array();
    while (($line = fgets($handle)) !== false) {
        preg_match_all("/ephone-dn\s+(\S*)\s+(\S*)/", $line, $matches, PREG_SET_ORDER);
        if (count($matches) > 0) {
            $id = $matches[0][1];
            $line2 = $line;
            while (!preg_match_all("/\s*!\s*/", $line2, $matches, PREG_SET_ORDER)) {
                $line2 = fgets($handle);
                //echo $line2;
                preg_match_all("/\s+number\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                if (count($matches) > 0) {
                    $listDN[$id]['number'] = $matches[0][1];
                }
                preg_match_all("/\s+label\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                if (count($matches) > 0) {
                    $listDN[$id]['label'] = $matches[0][1];
                }
                preg_match_all("/\s+name\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                if (count($matches) > 0) {
                    $listDN[$id]['name'] = $matches[0][1];
                }
                preg_match_all("/\s+call-forward noan\s+(\S+)\s+timeout\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                if (count($matches) > 0) {
                    $listDN[$id]['cfnoan'] = $matches[0][1];
                    $listDN[$id]['cfnoantimeout'] = $matches[0][2];
                }
                preg_match_all("/\s+call-forward busy\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                if (count($matches) > 0) {
                    $listDN[$id]['busy'] = $matches[0][1];
                }
                preg_match_all("/\s+pickup-group\s+(\S+)/", $line2, $matches, PREG_SET_ORDER);
                if (count($matches) > 0) {
                    $listDN[$id]['pickup-group'] = $matches[0][1];
                }
            }
        }
    }
    /*echo "\n";
    foreach ($listDN as $key => $value) {
        echo $key." ".print_r($value)."\n";
    }*/
    return $listDN;
}

$handle = fopen("uc500.log", "r");
$listDN = parseDN($handle);

$handle = fopen("uc500.log", "r");
parsePHONE($handle, $listDN);
fclose($handle);

?>
