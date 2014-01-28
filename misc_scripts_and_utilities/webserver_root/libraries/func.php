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
	return $registers;
} 

// Calculate exposure time in milliseconds
function  CalcExposureTime($time, $reg82, $reg85, $bits, $lvds) {
	$fot_overlap = 34 * ($reg82 & 0xFF) + 1;  
	return (($time - 1)*($reg85 + 1) + $fot_overlap) * ($bits/$lvds) * 1e3;  
} 

// Calculate exposure register values
function  CalcExposureRegisters($time, $reg82, $reg85, $bits, $lvds) {
	$fot_overlap = 34 * ($reg82 & 0xFF) + 1; 
	$a = (($time - $fot_overlap * ($bits/$lvds) * 1e3) / ($reg85 + 1) ) + 1;

	$temp [1] = $a/65536; 
	$temp [0] = $a - $a/65536;
	return $temp;
} 

?>
