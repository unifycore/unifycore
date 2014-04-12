<?php

ob_start();

// log raw request to rest.log
$msg = date("r")." -- ".trim($_SERVER['REQUEST_URI'])."\n";
file_put_contents('rest.log', $msg, FILE_APPEND);

// parse request
// eg.: rest_sim.php?/gprs/pdp/add&tlli=d2818615&apn=internet
if (!preg_match('/\?[\/]*([^&]+)&/', $_SERVER['REQUEST_URI'], $m)) 
	http_exit('400 Bad Request');
$cmd = trim($m[1]);



$res = null;
switch ($cmd) {
case 'gprs/pdp/add':
	// seed random based on tlli, same tlli should always get same IP :)
	srand(hexdec($_GET['tlli']));
	// assign user pseudo-random ip address from 172.20.0.0/16 range
	$res = array(
		'address'=>long2ip(ip2long('172.20.0.0')+rand(1,65534)),
		'dns1'=>'172.20.0.1',
		'dns2'=>'192.168.27.2',
	);
	break;

case 'gprs/pdp/remove':
	// free up assigned address
	$res = "ok";
	break;

default:
	// unknown command
	http_exit('404 Not Found', "cmd=$cmd");
	break;
}

// display results as json
header ('Content-type: application/json');
echo json_encode($res);
ob_end_flush();
exit;

function http_exit($err, $msg='') {
	ob_end_clean();
	header('HTTP/1.0 '.$err);
	echo "$err\n";
	if (!empty($msg))
		echo "($msg)";
	exit;
}

?>
