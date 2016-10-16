<?php

	header("Location: http://myownradio.biz/streams/intonewage");
	end();

?>
<!DOCTYPE html>
<html>
<head>
	
	<title>Into New Age</title>
	
	<script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
	<script src="https://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
	
	<script src="/js/jquery.jplayer.min.js"></script>
	<script src="/js/funkit.js"></script>
	
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	
	<meta property="og:title" content="Into New Age Radio" />
	<meta property="og:image" content="http://intonewage.myownradio.biz/images/new-age.jpg" />
	<meta property="og:url" content="http://intonewage.myownradio.biz/" />
	<meta property="og:description" content="Peaceful relaxing music! Nice after a day of hard work, or while working or studying! Non stop! Mail me for requests! (rayvermey@gmail.com)">
	
	<link href="/radio.css" rel="stylesheet" type="text/css">
		
	<meta name="viewport" content="initial-scale=0.8, minimum-scale=0.8, maximum-scale=0.8, user-scalable=no" />
	
<script>
	
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-58564686-1', 'auto');
  ga('send', 'pageview');

</script>
	
</head>
<body>
<div class="radioclass">
	<div id="audioplayer"></div>
	<div title="Click to Play" onclick="switchRadio()" style="cursor:pointer" class="play_container stopped">
		<img id="logo" src="/images/new-age.jpg">
		<img id="play" src="/images/video-play.png">
	</div>
	<span id="jfs">Into New Age</span><br><br>
	<div id="now">On Air:</div>
	<span id='title'></span>
</div>
<div id="copy">Copyright &copy; 2015 by <a href="mailto:rayvermey@gmail.com">Ray Vermey</a></div>
<div id="log"></div>
</body>
</html>