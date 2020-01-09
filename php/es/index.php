<?php
	
	$types = array('GPR', 'G98', 'GOA', 'NGO', 'GOB', 'GOC', 'BIO', 'G95', 'BIE', 'GLP', 'GNC');
	function downloadFiles() {
		global $types;
		foreach( $types as $name ) download( $name );
	}
	function download( $name ) {
		$url = "http://www6.mityc.es/aplicaciones/carburantes/eess_$name.zip";
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
		global $db;
		global $types;
		mysqli_query( $db, "TRUNCATE TABLE  `es_prices`" );
		mysqli_query( $db, "TRUNCATE TABLE  `es_stations`" );
		foreach( $types as $name ) parseFile( $name );
	}
	function parseFile( $name ) {
		global $db;
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
				$lat = $raw[0][1];
				$lng = $raw[0][0];
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
				if( !mysqli_fetch_assoc( mysqli_query( $db, "SELECT `id` FROM `es_stations` WHERE `id` Like \"$id\"" ) ) )
				mysqli_query( $db, "INSERT INTO `es_stations`(`id`, `name`, `open`, `lat`, `lng` ) VALUES ( \"$id\", \"$name\", \"$open\", \"$lat\", \"$lng\" )" ) or die( mysqli_error($db) );
				mysqli_query( $db, "INSERT INTO `es_prices`(`id`, `type`, `price` ) VALUES ( \"$id\", \"$type\", \"$price\" )" ) or die( mysqli_error($db) );
		}
	}
	function clearFiles() {
		global $types;
		foreach( $types as $name ) { unlink( "tmp/$name.zip" ); }
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
		global $db;
		$ret = [];
		$q = mysqli_query( $db, "SELECT *, ( 3959 * acos( cos( radians($lat) ) * cos( radians( lat ) ) * cos( radians(lng) - radians($lng)) + sin(radians($lat)) * sin( radians(lat)))) AS distance FROM `es_stations` HAVING `distance` < $rad" );
		while( ($station=mysqli_fetch_assoc($q))!=null ) {
			$station["address"] = getAdress( $station["id"] );
			$station["prices"] =  getPrices( $station["id"] );
			$ret[] = $station;
		}
		
		return $ret;
		return $ret;
	}
	function getStation( $id ) {
		global $db;
		$q = mysqli_query($db, "SELECT * FROM `es_stations` WHERE `id` Like \"$id\" ");
		$o = mysqli_fetch_assoc( $q );
		$o["address"] = getAdress( $id );
		$o["prices"]  = getPrices( $id );
		return $o;
	}
	function getPrices( $id ) {
		global $db;
		$ret = [];
		$q = mysqli_query( $db, "SELECT `type`, `price` FROM `es_prices` WHERE `id` Like \"$id\"" );
		while( ($price=mysqli_fetch_assoc($q))!=null ) {
			$ret[] = $price;
		}
		return $ret;
	}
	function getAdress( $id ) {
		global $db;
		$q = mysqli_query( $db, "SELECT `address` FROM `es_addresses` WHERE `id` Like \"$id\"" );
		if( ($address=mysqli_fetch_assoc($q))!=null ) {
			if( $address["address"] != "" ) return $address["address"];
		}
		
		$o = mysqli_fetch_assoc( mysqli_query($db, "SELECT `lat`, `lng` FROM `es_stations` WHERE `id` Like \"$id\" ") ); $lat = $o["lat"]; $lng = $o["lng"];
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng" );
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$data = curl_exec($ch);
		curl_close($ch);
		
		$address = json_decode($data,true)["results"][0]["formatted_address"];
		
		mysqli_query($db, "INSERT INTO `es_addresses` ( `id`, `address` ) VALUES ( \"$id\", \"$address\" )");
		
		return $address;
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
				getInfo( true, false );
			break;
			default: header( "Location: https://github.com/xXSparkeyy/harbour-spritradar" );
		}
	}
	function getInfo( $s, $sendmail=true ) {
		global $db;
		$lp = mysqli_fetch_assoc( mysqli_query($db, "SELECT COUNT(*) As length FROM `es_prices` WHERE 1" ) );
		$lp = $lp["length"];
		$ls = mysqli_fetch_assoc( mysqli_query($db, "SELECT COUNT(*) As length FROM `es_stations` WHERE 1" ) );
		$ls = $ls["length"];
		$s = $s&&($lp>0)&&($ls>0);
		if($sendmail) mail('lukasnagel99@gmail.com', '[ES] Cron Job: '.($s?"Succesfull":"Some Kinda Broke"), "Stationen: $ls | Preise: $lp" );
		else {
		    echo "{ 'stations': $ls, 'prices': $lp }";
		}
	}
	include "../index.php";
	include '../db.php';
	main();
?>
