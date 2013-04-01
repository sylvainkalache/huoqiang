window.onload=body_load;
function body_load()
{
	var return_code = document.getElementById("http_return_code");

	//get the text from the first child node - which should be a text node
	var httpCode = return_code.innerHTML;

	// GOOD
	if (httpCode === "No")
	{
		http_return_code.style.color = "green";
	}
	// No proxy available
	else if (httpCode === "No proxies available, please try your test later")
	{
		http_return_code.style.color = "orange";
	}
	// Website blocked
	else if (httpCode === "Yes")
	{
		http_return_code.style.color = "red";
	}

}

/*if responses.uniq[0].to_i == 200 or responses.uniq[0].to_i == 302 or responses.uniq[0].to_i == 301
  return 'No'
elsif responses.uniq[0].to_i == 4444
  return 'No servers available, please try your test later'
else
  return 'Yes'
end
*/