<?php
/*
----------------------------------------------------------------------------
--  detect_hotpixels.php
--	Hot Pixel detection example php script
--	Version 1.0
--
--  Copyright (C) 2013 Sebastian Pichelhofer
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------
*/

// the file to open as commandline argument
// (only raw16 is supported)
$filename = $argv[1];

echo "loading image: ".$filename."\n";

$handle = fopen($filename, "rb");
$fsize = filesize($filename);
$contents = fread($handle, $fsize);
fclose($handle);

$row = 0;
$coloumn = 0;

// pixels brighter than this treshhold are considered hot (values go from 0..4096)
$treshhold = 2000;

// iterate through each byte in the image
for($i = 0; $i < $fsize; $i++) { 
	$row = floor(($i/2)/4096);
	$coloumn = ($i/2) % 4096;

	// to make sure we dont iterate through the appended sensor registers	
	if ($row < 3072) {
		$asciiCharacter = $contents[$i+1].$contents[$i];
		$data = unpack("n*", $asciiCharacter);

		// compensate for four LSB padded zeros as the sensor 
		// provides 12 bit data but we store 16 bit values
		$value =$data[1]/16;
	
		if ($value > $treshhold) {
			echo "found hot pixel at ";
			echo "row: ".$row." coloumn: ".$coloumn." value: ".$value."\n";
		}
	}
	$i++;
}
echo "\n";
?>
