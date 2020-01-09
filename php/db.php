<?php function connectDB() {
	$host   = "";	
	$usr    = "";
	$passw  = "";
	$dbname = "";
	
	global $db;
	$db = mysqli_connect( $host, $usr, $passw );// or die ( "No connection" );
	mysqli_select_db($db, $dbname );// or die ( "no DB" );
	mysqli_query($db, "CREATE TABLE IF NOT EXISTS `es_prices` (`id` text NOT NULL,`type` text NOT NULL,`price` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysqli_query($db, "CREATE TABLE IF NOT EXISTS `es_stations` (`id` text NOT NULL,`name` text NOT NULL,`open` text NOT NULL,`lat` text NOT NULL,`lng` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysqli_query($db, "CREATE TABLE IF NOT EXISTS `es_addresses` (`id` text NOT NULL,`address` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysqli_query($db, "CREATE TABLE IF NOT EXISTS `it_prices` (`id` text NOT NULL,`type` text NOT NULL,`price` text NOT NULL,`self` tinyint(1) NOT NULL,`date` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysqli_query($db, "CREATE TABLE IF NOT EXISTS `it_stations` (`id` text NOT NULL,`name` text NOT NULL,`adress` text NOT NULL,`brand` text NOT NULL,`lat` text NOT NULL,`lng` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysqli_query($db, "CREATE TABLE IF NOT EXISTS `fr_stations` (`id` text NOT NULL,`content` text NOT NULL,`lat` text NOT NULL,`lng` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	
	return $db;
}
?>
