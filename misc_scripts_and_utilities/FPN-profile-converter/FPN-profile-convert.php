<?
/*
----------------------------------------------------------------------------
--  detect_hotpixels.php
--	convert the profile created by balance to a set of registerchanges
--	Version 1.0
--
--  Copyright (C) 2014 Sebastian Pichelhofer
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------
-- Usage:
-- php convert.php -o=darkframe-1ms-01.raw -f=0.0625 > fpn-cor.sh
*/


//print_r($argv);
if ($argv) {
 parse_str(implode('&', array_slice($argv, 1)), $_GET);
} 
//print_r($_GET);

$factor = $_GET["-f"];

$a = shell_exec("./balance -o ".$_GET["-o"]." 2>&1");
//$a = shell_exec("ls");
$b = explode("\n", $a);

//echo $b[0];
//echo $b[1];
//print_r($b);

for ($i=0; $i < count($b); $i++) {
	//echo $b[$i];
	if (strpos($b[$i],  "RO") !== false) {
		$line = $b[$i];
		$parts = explode("\t", $line);
		//print_r($parts);
		//echo "row";
 		if (($parts[1] < 3072) && (is_numeric($parts[1]))) {
			$rows[$parts[1]] = $parts[2];
		}
	}
	if (strpos($b[$i],  "CO") !== false) {
		$line = $b[$i];
		$parts = explode("\t", $line);
		//print_r($parts);
		//echo "row";
 		if (($parts[1] < 4096) && (is_numeric($parts[1]))) {
			$cols[$parts[1]] = $parts[2];
		}
	}
}
//print_r($rows);
//print_r($cols);
$index = 0;
$even_cols = 0x60300000;
$odd_cols = 0x60304000;
$even_rows = 0x60308000 ;
$odd_rows = 0x6030C000;
$offset = 0;

foreach ($rows as $rowkey => $rowvalue) {
	//echo "Row: ".$rowkey."\t\tOriginal Value: ".$rowvalue."\tCalculated Value: "
	//.$rowvalue * $factor."\t9bit signed: ".($rowvalue * $factor & 0x1FF )."\n";

	if ($rowkey % 2) {
		//odd rows
		$comment = "# Row: ".$rowkey;
		echo "devmem 0x".dechex($odd_rows + $offset)." 32 0x".dechex($rowvalue * $factor & 0x1FF )." ".$comment."\n";
	} else {
		//even rows
		$comment = "# Row: ".$rowkey;
		echo "devmem 0x".dechex($even_rows + $offset)." 32 0x".dechex($rowvalue * $factor & 0x1FF )." ".$comment."\n";
	}
	if (($rowkey % 2 == 1) && ($rowkey != 0)) {
		$offset+=4;
	}

	$index++;
	if ($index > 20) {
		//break;
	}
}
$index = 0;
$offset = 0;
foreach ($cols as $colkey => $colvalue) {
	if ($colkey % 2) {
		//odd columns
		$comment = "# Col: ".$colkey;
		echo "devmem 0x".dechex($odd_cols + $offset)." 32 0x".dechex($colvalue * $factor & 0x1FF )." ".$comment."\n";
	} else {
		//even columns
		$comment = "# Col: ".$colkey;
		echo "devmem 0x".dechex($even_cols + $offset)." 32 0x".dechex($colvalue * $factor & 0x1FF )." ".$comment."\n";
	}
	if (($colkey % 2 == 1) && ($colkey != 0)) {
		$offset+=4;
	}

	$index++;
	if ($index > 20) {
		//break;
	}
}

?>