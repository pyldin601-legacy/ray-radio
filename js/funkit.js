var radioMode = 1;

var npTitle = "";
var npOld = "";
var npListeners = 0;

$(document).ready(function(){
		$("#audioplayer").jPlayer({
		ready: function(e) {
			getNowPlaying();
			getStreamStatus();
		},
		error: function(e) { console.log(e.jPlayer.error.message); },
		progress: function(e) { progressLoad(e); },
		swfPath: "/js",
		supplied: "mp3",
		solution: "html, flash"
	});

	
});

function getNowPlaying() {
    $.get("http://myownradio.biz/api/v2/streams/getNowPlaying?stream_id=85", function (res) {
        npTitle = res.data.current.caption;
        var remaining = res.data.current.duration - (res.data.position - res.data.current.time_offset);
        var delay = Math.min(5000, remaining);
        showNowPlaying();
        setTimeout(function () {
            getNowPlaying();
        }, 5000);
    });
}

function getStreamStatus() {
    $.get("http://myownradio.biz/api/v2/streams/getOne?stream_id=85", function (res) {
        npListeners = res.data.listeners_count;
	$("#log").html("Listeners: " + npListeners);
        setTimeout(function () {
            getStreamStatus();
        }, 5000);
    });
}

function showNowPlaying() {
    if (npOld != npTitle) {
        $("#title").animate({opacity: 0}, 250, function () {
            $(this).text(npTitle);
            $(this).animate({opacity: 1}, 250);
        });
        npOld = npTitle;
    }
}

function playRadio() {
	
			$("#audioplayer").jPlayer("setMedia", {
				mp3 : "http://myownradio.biz:7778/audio?s=85&f=mp3_128k",
				m4a : "http://myownradio.biz:7778/audio?s=85&f=aacplus_64k"
			}).jPlayer("play");
}

function stopRadio() {
	$("#audioplayer").jPlayer("clearMedia");
}

function switchRadio() {
	radioMode = 1 - radioMode;
	if(radioMode == 1) {
		$(".play_container").addClass("stopped");
		stopRadio();
	} else {
		$(".play_container").removeClass("stopped");
		playRadio();
	}
}

function progressLoad(e) {
	
}

