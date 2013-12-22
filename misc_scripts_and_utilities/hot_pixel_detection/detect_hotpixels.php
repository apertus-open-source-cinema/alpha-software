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

$hot_pixel_count = 0;

// iterate through each byte in the image
for($i = 0; $i < $fsize; $i++) { 
	$row = floor(($i/2)/3072);
	$coloumn = ($i/2) % 4096;
	
	// to make sure we dont iterate through the appended sensor registers	
	if ($row < 3072) {
		
		// output progress percentages
		if (($row > 10) && ($row % 307 == 0) && ($coloumn == 0))
			echo round($row/3072*100)."%..";

		$asciiCharacter = $contents[$i+1].$contents[$i];
		$data = unpack("n*", $asciiCharacter);

		// compensate for four LSB padded zeros as the sensor 
		// provides 12 bit data but we store 16 bit values
		$value =$data[1]/16;
	
		if ($value > $treshhold) {
			//echo "found hot pixel at ";
			//echo "row: ".$row." coloumn: ".$coloumn." value: ".$value."\n";
			$hot_pixel[$hot_pixel_count]['X'] = $coloumn;
			$hot_pixel[$hot_pixel_count]['Y'] = $row;
			$hot_pixel[$hot_pixel_count++]['val'] = $value;
		}
	}
	$i++;
}
echo "\nfound: ".$hot_pixel_count." hot pixels\n";
$i = 1;
$j = 0;
echo "Pixel\tColoumn\tRow\tValue\n";
foreach ($hot_pixel as $pixel) {
	echo $i++.":\t".$pixel['X']."\t".$pixel['Y']."\t".$pixel['val']."\n";

	// calculate distance between 2 hot pixels
	foreach ($hot_pixel as $pixel2) {
		 $distance = round(sqrt((abs($pixel['X']-$pixel2['X']))*(abs($pixel['X']-$pixel2['X']))+(abs($pixel['Y']-$pixel2['Y']))*(abs($pixel['Y']-$pixel2['Y'])))).", " ;
		if (($distance > 1) && ($distance < 3))
			$j++;
	}
}
echo "Number of 2 pixel clusters (according to sensor specification): ". $j/2 ."\n";
?>
