<html>
<head>
<title>Fuck mcdvoice</title>
</head>
<body>
<?php
if ($_SERVER["REQUEST_METHOD"] == "POST")
{
	$sCode = validatyInput($_POST["surveyCode"]);
	$key = validatyInput($_POST["key"]);
	// Warning: forced HTTPS
	if($key == '0000' && preg_match('/[-0-9]*/', $sCode) == 1)
	{
        	echo 'Please wait while the program is running...';
		exec("./php_agent.fish $sCode", $cstdout);
		_log("[mcd] working on sCode `$sCode`");
		foreach($cstdout as $outLine)
			echo formatedEcho($outLine);
	}
	else
	{
		echo formatedEcho("Incorrect sCode or key.");
	}
	printForm($sCode, $key);
}
else
{
	printForm('', '');
}

function validatyInput($data)
{
	$data = trim($data);
	$data = stripslashes($data);
	$data = htmlspecialchars($data);
	return $data;
}
function formatedEcho($str)
{
	$str = "<p style=\"font-size:40px\">$str</p>";
	return $str;
}
function printForm($sCode, $key)
{
	echo '<form action="index.php" method="post" style="width:70%;font-size:40px">';
	echo "Survey Code: <input type='text' name='surveyCode' value='$sCode' style='width:70%;height:100px;font-size:40px'><br>";
	echo "Key: <input type='password' name='key' value='$key' style='width=70%;height:100px;font-size:40px'><br>";
	echo '<input type="submit" style="width:95%;height:150px;font-size:40px"></form>';
}
function _log($txt)
{
	$myfile = file_put_contents('/var/log/recolic/p.log', $txt.PHP_EOL , FILE_APPEND | LOCK_EX);
}
?>
</body>
</html>

