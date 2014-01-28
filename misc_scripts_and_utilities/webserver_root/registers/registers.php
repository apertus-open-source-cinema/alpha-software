<!DOCTYPE html>
<html>
  <head>
    <title>apertus&deg; Axiom Alpha Registers</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  </head>
  <body>
  	<script src="../libraries/jquery-2.0.3.min.js"></script>
	<script>
	function dex2hex(d) {return d.toString(16);}
	
	$( document ).ready(function() {
	<?php
		// generate javascript code with PHP
		// these functions take care of the conversion between hexadecimal and decimal values of each register
		for ($a = 0; $a < 128; $a++) {
			echo '$( "#'.$a.'dec" ).change(function( event ) {
				var decvalue = parseInt($( "#'.$a.'dec" ).val());
				$( "#'.$a.'hex").val("0x" + dex2hex(decvalue));
				$( "#'.$a.'apply").prop("checked", true);
			});
			
			$( "#'.$a.'hex" ).change(function( event ) {
				var decvalue = parseInt($( "#'.$a.'hex" ).val(), 16);
				$( "#'.$a.'dec").val(decvalue);
				$( "#'.$a.'apply").prop("checked", true);
			});';
		}
		
		// Special human readable registers need special javascript functions
		echo '$( "#exptime" ).change(function( event ) {
				$( "#exptimeapply").prop("checked", true);
			});';
		echo '$( "#exptime2" ).change(function( event ) {
				$( "#exptime2apply").prop("checked", true);
			});';
	?>
	});
	</script>

<?php
include("../libraries/func.php");

// Load register names from external file
include("registernames.php");

// if no page is selected show all registers by default
if (!isset($_GET['page'])) {
	$page = "all";
} else {
	$page = $_GET['page'];
}

?>

  <div style="padding:10px;">
  <a class="btn btn-primary" href="/index.php">Back</a> 
  <h1>apertus&deg; Axiom Alpha Registers</h1>
  <!-- 
  The top buttons group registers together in a somehow logical way.
  The syntax: simply list all register indexes that should be displayed as GET parameters (key without value)
  -->
  <a class="btn <?php if ($page == "all") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=all">Show All</a> 
  <a class="btn <?php if ($page == "window") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=window&1&2&3&4&5&6&7&8&9&10&11&12&13&14&15&16&17&18&19&20&21&22&23&24&25&26&27&28&29&30&31&32&33&34&35&36&37&38&39&40&41&42&43&44&45&46&47&48&49&50&51&52&53&54&55&56&57&58&59&60&61&62&63&64&65">Windowing</a> 
  <a class="btn <?php if ($page == "gain") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=gain&87&88&115&116&117&118">Gain &amp; Levels</a> 
  <a class="btn <?php if ($page == "colors") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=colors&68&118">Colors</a> 
  <a class="btn <?php if ($page == "time") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=time&70&71&72">Timing</a> 
  <a class="btn <?php if ($page == "hdr") { echo "btn-success"; } else { echo "btn-primary"; } ?>" href="registers.php?page=hdr&71&72&73&74&75&76&77&78&79&80&106&118">HDR</a> 
  <br />
  <br />
  
<?php
$registers_to_show = null;
// Which registers to display?
for ($b = 0; $b < 128; $b++) {
	if (isset($_GET[$b])) {
		$registers_to_show[count($registers_to_show)] = $b;
	}
} 

//debug
//print_r($registers_to_show);

// This reads all the register values into one big array via a shell script
$registers = GetRegisters();


//Show an alert notice message at the top when registers are being changed
$alert = "";
if (isset($_POST["form1"])) {
	if ($_POST["form1"] == "Apply") {
		for ($j = 0; $j < 128; $j++) {
			if ((isset($_POST[$j."apply"]) && ($_POST[$j."apply"] == "on"))) {
				SetRegisterValue($j, $_POST[$j."dec"]);
				$alert .= "Register: ".$j." set to: ".$_POST[$j."dec"]."<br>\n";
			}
		}
		
		//Special Register handling
		if ((isset($_POST["exptimeapply"]) && ($_POST["exptimeapply"] == "on"))) {

			$regs = CalcExposureRegisters($_POST["exptime"], $registers[82], $registers[85], 12, 300000000);
			$alert .= "Exposure Time set to: ".$_POST["exptime"]." ms<br>\n";
			$alert .= "Register 71 set to: ". $regs[0] ."<br>\n";
			$alert .= "Register 72 set to: ". $regs[1] ."<br>\n";
			SetRegisterValue(71, $regs[0]);
			$registers[71] = strtoupper(dechex($regs[0]));
			SetRegisterValue(72, $regs[1]);
			$registers[72] = strtoupper(dechex($regs[1]));
		}
		
		// Print Notice Alert
		echo "<div class=\"alert alert-success\">";
		echo $alert;
		echo "</div>"; 
	}
}

// The big register table
echo "<form method=\"POST\"><table class=\"table table-hover table-bordered\"  style=\"width:800px\">";
echo "<tr><th style=\"text-align:center;\" colspan=\"2\">Register</th>
<th style=\"text-align:center;\" colspan=\"2\" align=\"center\">Current Value</th>
<th style=\"text-align:center;\" colspan=\"3\">New Value</th></tr>";
echo "<tr><th style=\"text-align:center;\">Index</th><th style=\"text-align:center;\">Name</th><th style=\"text-align:center;\">dec</th>
<th style=\"text-align:center;\">hex</th><th style=\"text-align:center;\">dec</th><th style=\"text-align:center;\">hex</th><th style=\"text-align:center;\">Apply</th></tr>";
// Show All Registers
if ($page == "all") {
	for ($i = 0; $i < 128; $i++) {
		echo "<tr><td>".$i."</td>
		<td>".$registernames[$i]."</td>
		<td>".hexdec($registers[$i])."</td>
		<td>0x".$registers[$i]."</td>
		<td><input type=\"text\" id=\"".$i."dec\" name=\"".$i."dec\" size=\"6\" value=\"".hexdec($registers[$i])."\"></td>
		<td><input type=\"text\" id=\"".$i."hex\" name=\"".$i."hex\" size=\"6\" value=\"0x".$registers[$i]."\"></td>
		<td><input type=\"checkbox\" id=\"".$i."apply\" name=\"".$i."apply\"></td></tr>";
	}
} else {
	// Show the selected group of registers as defined in the GET Parameters
	foreach ($registers_to_show as $register_to_show) {
		$i = $register_to_show;
		echo "<tr><td>".$i."</td>
		<td>".$registernames[$i]."</td>
		<td>".hexdec($registers[$i])."</td>
		<td>0x".$registers[$i]."</td>
		<td><input type=\"text\" id=\"".$i."dec\" name=\"".$i."dec\" size=\"6\" value=\"".hexdec($registers[$i])."\"></td>
		<td><input type=\"text\" id=\"".$i."hex\" name=\"".$i."hex\" size=\"6\" value=\"0x".$registers[$i]."\"></td>
		<td><input type=\"checkbox\" id=\"".$i."apply\" name=\"".$i."apply\"></td></tr>";
		
		// Special Register Fields to make some more human read-/writeable
		if ($i == 72) {
			$exposure_ns = CalcExposureTime(hexdec($registers[$i])*65536+hexdec($registers[$i-1]), $registers[82], $registers[85], 12, 300000000);
			echo "<tr class=\"success\"><td></td>
				<td>Exposure Time</td>
				<td>".round($exposure_ns, 3)." ms</td>
				<td></td>
				<td><input type=\"text\" id=\"exptime\" name=\"exptime\" size=\"8\" value=\"".round($exposure_ns, 3)."\"> ms</td>
				<td></td>
				<td><input type=\"checkbox\" id=\"exptimeapply\" name=\"exptimeapply\"></td></tr>";
		}
		if ($i == 74) {
			$exposure_ns = CalcExposureTime(hexdec($registers[$i])*65536+hexdec($registers[$i-1]), $registers[82], $registers[85], 12, 300000000);
			echo "<tr class=\"success\"><td></td>
				<td>Exposure Time 2</td>
				<td>".round($exposure_ns, 3)." ms</td>
				<td></td>
				<td><input type=\"text\" id=\"exptime2\" name=\"exptime2\" size=\"8\" value=\"".round($exposure_ns, 3)."\"> ms</td>
				<td></td>
				<td><input type=\"checkbox\" id=\"exptime2apply\" name=\"exptime2apply\"></td></tr>";
		}
	}
}
echo "</table>
<input class=\"btn btn-primary\" type=\"submit\" name=\"form1\" value=\"Apply\"></form>";

?>
   </div>
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://code.jquery.com/jquery.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../libraries/bootstrap/js/bootstrap.min.js"></script>
  </body>
</html>
