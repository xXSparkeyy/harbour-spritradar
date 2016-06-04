<?php function connectDB() {
	mysql_connect( "host", "usr", "Passwd" ) or die ( "No connection" );
	mysql_select_db( "table" ) or die ( "no DB" );
	mysql_query( "CREATE TABLE IF NOT EXISTS `es_prices` (`id` text NOT NULL,`type` text NOT NULL,`price` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysql_query( "CREATE TABLE IF NOT EXISTS `es_stations` (`id` text NOT NULL,`name` text NOT NULL,`open` text NOT NULL,`lat` text NOT NULL,`lng` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
}
?>
