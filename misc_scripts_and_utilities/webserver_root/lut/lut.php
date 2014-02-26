<?php
include("../libraries/func.php");
// 4096 x 16 bit values per channel (4 channels in total)
$lut[0] = GetLUTs();


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
    <script src="http://d3lp1msu2r81bx.cloudfront.net/kjs/js/lib/kinetic-v5.0.1.min.js"></script>
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

	  var rect = new Kinetic.Rect({
        x: 0,
        y: 0,
        width: 532,
        height: 320,
        fill: 'black'
      });
      layer.add(rect);
	  
	  var lutaxis1Line = new Kinetic.Line({
		points: [10,310, 522, 310],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis1Line);
	  var lutaxis2Line = new Kinetic.Line({
		points: [10,310, 10, 10],
        stroke: '#555',
        strokeWidth: 1,
        lineCap: 'round',
        lineJoin: 'round'
      });
      layer.add(lutaxis2Line);
	  
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