<!DOCTYPE html>
<html>
  <head>
    <title>apertus&deg; AxiomVision</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
	
	<style>
		body { background-color:black; color:white; }
		.exposuretime-label { font-size:1.5em; display: inline; }
		.exposuretime-value { font-size:2em; display: inline; }
		.gamma-label { font-size:1.5em; display: inline; }
		.gamma-value { font-size:2em; display: inline; }
    </style>
  </head>
  <body>
  <script src="../libraries/jquery-2.0.3.min.js"></script>
  
<?php
// This reads all the register values into one big array via a shell script
include("../libraries/func.php");
$registers = GetRegisters();

$EVRow = array(1/6400, 1/3200, 1/1600, 1/800, 1/400, 1/200, 1/100, 1/50, 1/25, 1/12, 1/6, 1/3);
$GammaRow = array(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2);

if (isset($_GET["evindex"]))
	$EVIndex = $_GET["evindex"];
else
	$EVIndex = 5;
	
if (isset($_GET["gammaindex"]))
	$GammaIndex = $_GET["gammaindex"];
else
	$GammaIndex = 6;
	
if (isset($_GET["set"])) {
	switch ($_GET["set"]) {
		case "evindex":
			SetExposureTime($EVRow[$EVIndex]*1000);
			break;
		case "gammaindex":
			echo SetGamma($GammaRow[$GammaIndex]);
			break;
	}
}

if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "livevideostart")) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; fil_reg 11 0x01000100\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "livevideostop")) {
	$cmd = "busybox su -c \". ../libraries/cmv.func ; fil_reg 11 0x0\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "hdmihalf")) {
	$cmd = "busybox su -c \". ../libraries/hdmi.func ; pll_reg 22 0x2106\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "hdmifull")) {
	$cmd = "busybox su -c \". ../libraries/hdmi.func ; pll_reg 22 0x2083\"";
	$value = shell_exec($cmd);
	echo $value;
}
if ((isset($_GET["cmd"])) && ($_GET["cmd"] == "sawtoothlut")) {
	$cmd = "busybox su -c \"cd ../libraries/; ./lut_conf.sh -M 0x100000 -N 4096\"";
	shell_exec($cmd);
}

$exposure_ns = GetExposureTime();

// Exposure Time
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=evindex&evindex=". ($EVIndex-1) ."\">-</a> ";
echo "<div class=\"exposuretime-label\">Exposure: </div> ";
echo "<div class=\"exposuretime-value\">".round($exposure_ns, 3)." ms</div> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=evindex&evindex=". ($EVIndex+1) ."\">+</a><br /><br />";

// Gamma
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gammaindex&gammaindex=". ($GammaIndex-1) ."\">-</a> ";
echo "<div class=\"exposuretime-label\">Gamma: </div> ";
echo "<div class=\"exposuretime-value\">".$GammaRow[$GammaIndex]."</div> ";
echo "<a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?set=gammaindex&gammaindex=". ($GammaIndex+1) ."\">+</a><br /><br />";

// LUTs
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=sawtoothlut\">Sawtooth LUT</a></p>";

// Misc
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=livevideostart\">Start Live Video</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=livevideostop\">Stop Live Video</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=hdmihalf\">Set HDMI to Half Frequency</a></p>";
echo "<p><a class=\"btn btn-primary btn-lg\" href=\"AxiomVision.php?cmd=hdmifull\">Set HDMI to Full Frequency</a></p>";
//echo "<div class=\"gamma-label\">Gamma: </div>";
//echo "<div class=\"gamma-value\">".round($exposure_ns, 3)." ms</div>";
?>

    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../libraries/bootstrap/js/bootstrap.min.js"></script>
  </body>
</html>