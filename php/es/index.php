<?php
	
	$types = ['GPR', 'G98', 'GOA', 'NGO', 'GOB', 'GOC', 'BIO', 'G95', 'BIE', 'GLP', 'GNC'];
	function downloadFiles() {
		global $types;
		foreach( $types as $name ) download( $name );
	}
	function download( $name ) {
		mkdir( "/tmp" );
		$url = "www6.mityc.es/aplicaciones/carburantes/eess_$name.zip";
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$data = curl_exec($ch);
		curl_close($ch);
		$f = fopen( "tmp/$name.zip", "w+" );
		fwrite( $f, $data );
		fclose( $f );
	}
	function parseFiles() {
		global $types;
		mysql_query( "TRUNCATE TABLE  `es_prices`" );
		mysql_query( "TRUNCATE TABLE  `es_stations`" );
		foreach( $types as $name ) parseFile( $name );
	}
	function parseFile( $name ) {
		$zip = zip_open( "tmp/$name.zip" );
		$entry = zip_read( $zip );
		zip_entry_open( $zip, $entry, "r" );
		$csv = zip_entry_read( $entry, zip_entry_filesize( $entry ) );
		zip_entry_close( $entry );
		zip_close( $zip );
		$csv = explode( "\n", $csv );
		unset($csv[1]);unset($csv[0]);
		$type = $name;
		foreach( $csv as $raw ) {
			$raw = explode( "\"", $raw );
			$raw[0] = explode( ", ", $raw[0] );
				$lat = $raw[0][0];
				$lng = $raw[0][1];
			$raw = explode( " ", $raw[1] );
				$open = $raw[count($raw)-3];
				$price = str_replace(",", ".", $raw[count($raw)-2] );
				if( $raw[count($raw)-4] == "Horario" ) {
					$open = "Horario $open";
					unset($raw[count($raw)-1]);
				}
				unset($raw[count($raw)-1]);unset($raw[count($raw)-1]);unset($raw[count($raw)-1]);
				$name = rtrim( implode( " ", $raw ), ":" );
				$id = md5( "$lat+$lng+$name" );
				if( !mysql_fetch_assoc( mysql_query( "SELECT `id` FROM `es_stations` WHERE `id` Like \"$id\"" ) ) )
				mysql_query( "INSERT INTO `es_stations`(`id`, `name`, `open`, `lat`, `lng` ) VALUES ( \"$id\", \"$name\", \"$open\", \"$lat\", \"$lng\" )" ) or die( mysql_error() );
				mysql_query( "INSERT INTO `es_prices`(`id`, `type`, `price` ) VALUES ( \"$id\", \"$type\", \"$price\" )" ) or die( "asfs".mysql_error() );
		}
	}
	function clearFiles() {
		global $types;
		foreach( $types as $name ) unlink( "tmp/$name.zip" );
	}
		function getDistance($lat1, $lon1, $lat2, $lon2) {
		$theta = $lon1 - $lon2;
		$dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
		$dist = acos($dist);
		$dist = rad2deg($dist);
		$dist = $dist * 60 * 1.1515 * 1.609344;
		return $dist;
	}
	function getStations($lat, $lng, $rad) {
		$ret = array();
		$q = mysql_query( "SELECT * FROM `es_stations`" );
		while( ($station=mysql_fetch_assoc($q))!=null ) {
			$station["distance"] = ceil(getDistance( (double)$station["lat"], (double)$station["lng"], (double)$lat, (double)$lng )*1000);
			if( $station["distance"] < $rad*1000 ) {
				$station["prices"] = getPrices( $station["id"] );
				$ret[] = $station;
			}
		}
		return $ret;
	}
	function getStation( $id ) {
		$o = mysql_fetch_assoc( mysql_query("SELECT * FROM `es_stations` WHERE `id` Like \"$id\" ") );
		$o["prices"] = getPrices( $id );
		return $o;
	}
	function getPrices( $id ) {
		$ret = array();
		$q = mysql_query( "SELECT `type`, `price` FROM `es_prices` WHERE `id` Like \"$id\"" );
		while( ($price=mysql_fetch_assoc($q))!=null ) {
			$ret[] = $price;
		}
		return $ret;
	}
	function x( $s ) {
		return str_replace( "\"","\\\"",$s );
	}
	function cron() {
		connectDB();
		downloadFiles();
		parseFiles();
	}
	function main() {
		switch( $_GET["get"] ) {
			case "stations":
				connectDB();
				echo json_encode( getStations( $_GET["lat"], $_GET["lng"], $_GET["radius"] ) );
			break;
			case "station":
				connectDB();
				echo json_encode( getStation( $_GET["id"] ) );
			break;
			case "cron":
				global $cronjob_key;
				if( $_GET["key"] == $cronjob_key ) cron();
			break;
			case "info":
				connectDB();
				getInfo( true );
			break;
			default: header( "Location: https://github.com/xXSparkeyy/harbour-spritradar" );
		}
	}
	function getInfo( $s ) {
		$lp = mysql_fetch_assoc( mysql_query("SELECT COUNT(*) As length FROM `it_prices` WHERE 1" ) )["length"];
		$ls = mysql_fetch_assoc( mysql_query("SELECT COUNT(*) As length FROM `it_stations` WHERE 1" ) )["length"];
		$s = $s&&($lp>0)&&($ls>0);
		mail('', 'Cron Job: '.($s?"Succesfull":"Some Kinda Broke"), "Stationen: $ls | Preise: $lp" );
	}
	include "../index.php";
	include 'db.php';
	main();
?>
