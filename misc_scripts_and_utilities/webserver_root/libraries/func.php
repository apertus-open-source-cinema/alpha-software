<?php

function GetRegisterValue($register) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; cmv_reg ".$register."\"";

	return shell_exec($cmd);
} 

function SetRegisterValue($register, $value) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; cmv_reg ".$register." ".$value."\"";

	return shell_exec($cmd);
} 

function GetRegisters() {
	$cmd = "busybox su -c \"./registers.sh\"";
	$return = shell_exec($cmd);
	$registers = explode("\n", $return);
	for ($i = 0; $i < 128; $i++) {
		$registers[$i] = substr($registers[$i], 6);
	}
	return $registers;
} 

// Calculate exposure time in milliseconds
function  CalcExposureTime($time, $reg82, $reg85, $bits, $lvds) {
	$fot_overlap = (34 * (hexdec($reg82) & 0x00FF)) + 1;  
	return (($time - 1) * (hexdec($reg85) + 1) + $fot_overlap) * ($bits/$lvds) * 1e3;
}

// Calculate exposure register values
function  CalcExposureRegisters($time, $reg82, $reg85, $bits, $lvds) {
	$fot_overlap = (34 * (hexdec($reg82) & 0x00FF)) + 1; 
	$a = ((($time / (($bits/$lvds) * 1e3)) - $fot_overlap) / (hexdec($reg85) + 1)) + 1;

	$temp[1] = round($a/65536); 
	$temp[0] = round($a - $a/65536);
	return $temp;
}

?>
