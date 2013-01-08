var opts = {
	lines: 10, // The number of lines to draw
	length: 0, // The length of each line
	width: 9, // The line thickness
	radius: 30, // The radius of the inner circle
	rotate: 0, // The rotation offset
	color: '#fff', // #rgb or #rrggbb
	speed: 1.2, // Rounds per second
	trail: 100, // Afterglow percentage
	shadow: false, // Whether to render a shadow
	hwaccel: false, // Whether to use hardware acceleration
	className: 'spinner', // The CSS class to assign to the spinner
	zIndex: 2e9, // The z-index (defaults to 2000000000)
	top: 'auto', // Top position relative to parent in px
	left: 'auto' // Left position relative to parent in px
};
var target = document.getElementById('spin');
var spinner = new Spinner(opts).spin(target);
function spin_stop()
{
	spinner.stop();
}

function spin_start()
{
	var x=document.forms["mainForm"]["url"].value;
	if (x==null || x=="")
	{
 		document.getElementById("address-field").className = "address-wrong";
		return false;
	}
	else
	{
		spinner.spin(target);
	}
}