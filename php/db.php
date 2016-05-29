<?php function connectDB() {
	mysql_connect( "", "", "" ) or die ( "No connection" );
	mysql_select_db( "" ) or die ( "no DB" );
	mysql_query( "CREATE TABLE IF NOT EXISTS `prices` (`id` text NOT NULL,`type` text NOT NULL,`price` text NOT NULL,`self` tinyint(1) NOT NULL,`date` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
	mysql_query( "CREATE TABLE IF NOT EXISTS `stations` (`id` text NOT NULL,`name` text NOT NULL,`adress` text NOT NULL,`brand` text NOT NULL,`lat` text NOT NULL,`lng` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1" );
}
?>
