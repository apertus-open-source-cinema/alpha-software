<?php
include("../libraries/func.php");
// 4096 x 16 bit values per channel (4 channels in total)
$lut[0] = GetLUTs(0);
$lut[1] = GetLUTs(1);
$lut[2] = GetLUTs(2);
$lut[3] = GetLUTs(3);

?>
<!DOCTYPE HTML>
<html>
  <head>
    <style>
      body {
        padding: 10px;
      }
    </style>
    <title>apertus&deg; Axiom Alpha LUT Graph</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="../libraries/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  </head>
  <body>
  <body>
    <p><a class="btn btn-primary" href="/index.php">Back</a></p>
    <h1 style="margin-top: 0px; padding-top:10px">apertus&deg; Axiom Alpha LUT Graph</h1>
    <div id="container"></div>
    <script src="kinetic-v5.0.1.min.js"></script>
    <script defer="defer">
	<?php  
		$padding = 10;
		$height = 300;
		$width = 512;
	?>
      var stage = new Kinetic.Stage({
        container: 'container',
        width: 532,
        height: 320
      });

      var layer = new Kinetic.Layer();

	  //black background
	  var rect = new Kinetic.Rect({
        x: 0,
        y: 0,
        width: <? echo $width+2*$padding; ?>,
        height: <? echo $height+2*$padding; ?>,
        fill: 'black'
      });
      layer.add(rect);
	  
	  //10% background fill
	  var rect2 = new Kinetic.Rect({
        x: <? echo $padding; ?>,
        y: <? echo $padding; ?>,
        width: <? echo $width*0.1; ?>,
        height: <? echo $height; ?>,
        fill: '#080808'
      });
      layer.add(rect2);
	  
	  //50% background fill
	  var rect3 = new Kinetic.Rect({
        x: <? echo $padding+$width*0.1; ?>,
        y: <? echo $padding; ?>,
        width: <? echo $width*0.4; ?>,
        height: <? echo $height; ?>,
        fill: '#101010'
      });
      layer.add(rect3);
	  
	  //90% background fill
	  var rect4 = new Kinetic.Rect({
        x: <? echo $padding+$width*0.5; ?>,
        y: <? echo $padding; ?>,
        width: <? echo $width*0.4; ?>,
        height: <? echo $height; ?>,
        fill: '#181818'
      });
      layer.add(rect4);
	  
	  //100% background fill
	  var rect5 = new Kinetic.Rect({
        x: <? echo $padding+$width*0.9; ?>,
        y: <? echo $padding; ?>,
        width: <? echo $width*0.1; ?>,
        height: <? echo $height; ?>,
        fill: '#202020'
      });
      layer.add(rect5);
	  
	  //horizontal 0% line
	  var lutaxis1Line = new Kinetic.Line({
		points: [<? echo $padding; ?>,<? echo $height+$padding; ?>, <? echo $width+$padding; ?>, <? echo $height+$padding; ?>],
        stroke: '#999',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis1Line);
	  
	  //horizontal 100% line
	  var lutaxis3Line = new Kinetic.Line({
		points: [<? echo $padding; ?>,<? echo $padding; ?>, <? echo $width+$padding; ?>, <? echo $padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis3Line);
	  
	  //vertical 0% line
	  var lutaxis2Line = new Kinetic.Line({
		points: [<? echo $padding; ?>,310, <? echo $padding; ?>, <? echo $padding; ?>],
        stroke: '#999',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis2Line);
	  
	  //vertical 10% line
	  var lutindicatorLine01 = new Kinetic.Line({
		points: [<? echo $padding+0.1*$width; ?>, <? echo $height+$padding; ?>, <? echo $padding+0.1*$width; ?>, <? echo $padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine01);
	  
	  //vertical 50% line
	  var lutindicatorLine02 = new Kinetic.Line({
		points: [<? echo $padding+0.5*$width; ?>, <? echo $height+$padding; ?>, <? echo $padding+0.5*$width; ?>, <? echo $padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine02);
	  
	  //vertical 90% line
	  var lutindicatorLine02 = new Kinetic.Line({
		points: [<? echo $padding+0.9*$width; ?>, <? echo $height+$padding; ?>, <? echo $padding+0.9*$width; ?>, <? echo $padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine02);
	  
	  //vertical 100% line
	  var lutindicatorLine02 = new Kinetic.Line({
		points: [<? echo $padding+$width; ?>, <? echo $height+$padding; ?>, <? echo $padding+$width; ?>, <? echo $padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine02);
	  
	  //horizontal 50% line
	  var lutindicatorLine03 = new Kinetic.Line({
		points: [<? echo $padding; ?>, <? echo 0.5*$height+$padding; ?>, <? echo $padding+$width; ?>, <? echo 0.5*$height+$padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine03);
	  
	  //horizontal 10% line
	  var lutindicatorLine04 = new Kinetic.Line({
		points: [<? echo $padding; ?>, <? echo 0.1*$height+$padding; ?>, <? echo $padding+$width; ?>, <? echo 0.1*$height+$padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine04);
	  
	  //horizontal 90% line
	  var lutindicatorLine05 = new Kinetic.Line({
		points: [<? echo $padding; ?>, <? echo 0.9*$height+$padding; ?>, <? echo $padding+$width; ?>, <? echo 0.9*$height+$padding; ?>],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutindicatorLine05);
	  
	  //vertical 50% label
	  var lutindicatorText01 = new Kinetic.Text({
        x: <? echo (($width+2*$padding)/2)+2; ?>,
        y: <? echo $padding+4; ?>,
        text: '50%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText01);
	  
	  //vertical 10% label
	  var lutindicatorText02 = new Kinetic.Text({
        x: <? echo (($width)*0.1+$padding)+2; ?>,
        y: <? echo $padding+4; ?>,
        text: '10%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText02);
	  
	  //vertical 90% label
	  var lutindicatorText03 = new Kinetic.Text({
        x: <? echo (($width)*0.9+$padding)+2; ?>,
        y: <? echo $padding+4; ?>,
        text: '90%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText03);
	  
	  //horizontal 50% label
	  var lutindicatorText04 = new Kinetic.Text({
        x: <? echo $padding+2; ?>,
        y: <? echo (($height)*0.5+$padding)+3; ?>,
        text: '50%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText04);
	  
	  //horizontal 10% label
	  var lutindicatorText05 = new Kinetic.Text({
        x: <? echo $padding+2; ?>,
        y: <? echo (($height)*0.9+$padding)+3; ?>,
        text: '10%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText05);
	  
	  //horizontal 90% label
	  var lutindicatorText06 = new Kinetic.Text({
        x: <? echo $padding+2; ?>,
        y: <? echo (($height)*0.1+$padding)+3; ?>,
        text: '90%',
        fontSize: 6,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText06);
	  
	  //input label
	  var lutindicatorText07 = new Kinetic.Text({
        x: <? echo 1; ?>,
        y: <? echo (($height)*0.5+$padding)+12; ?>,
        text: 'INPUT',
        fontSize: 8,
        fontFamily: 'Arial',
		rotation: 270,
        fill: '#777'
      });
	  layer.add(lutindicatorText07);
	  
	  //output label
	  var lutindicatorText08 = new Kinetic.Text({
        x: <? echo (($width)*0.5+$padding)-18; ?>,
        y: <? echo $height+2*$padding-8; ?>,
        text: 'OUTPUT',
        fontSize: 8,
        fontFamily: 'Arial',
        fill: '#777'
      });
	  layer.add(lutindicatorText08);
	  
	  var lutLine = new Kinetic.Line({
		<?php 
		
		echo "points: [";
		for ($i = 0; $i < 256; $i++) {
			if ($i == 255) {
				echo ($padding+$i*2).", ".($padding + $height - ($lut[0][$i]/65536*$height));
			} else {
				echo ($padding+$i*2).", ".($padding + $height - ($lut[0][$i]/65536*$height)).", ";
			}
		}
		echo "],";
		?>
        stroke: '#FF0000',
        strokeWidth: 2,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutLine);
	  
      stage.add(layer);
    </script>
  </body>
</html>