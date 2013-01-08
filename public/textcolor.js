window.onload=body_load;
function body_load()
{
	var return_code = document.getElementById("return_code");

	//get the text from the first child node - which should be a text node
	var currentText = return_code.innerHTML;

	//check for 'one' and assign this table cell's background color accordingly
	if (currentText === "No")
	{
		return_code.style.color = "green";
	}
	else if (currentText === "No servers available, please try your test later")
	{
		return_code.style.color = "orange";
	}
	else if (currentText === "Yes")
	{
		return_code.style.color = "red";
	}

}