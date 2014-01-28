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

?>
