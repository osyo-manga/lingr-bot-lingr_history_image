

var page = require('webpage').create();

var url    = phantom.args[0].split(/#/)[0];
var anchor = phantom.args[0].split(/#/)[1];
var output = phantom.args[1];


page.open(url, function (status) {
	var hash = page.evaluate(function(anchor) {
		return window.pageYOffset + document.getElementById(anchor).offsetTop;
	}, anchor);

	page.clipRect = { top: hash - 4, left: 0, width: 800, height: 200 };
	page.render(output);
	phantom.exit();
});

