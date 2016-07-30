<?php

	function cron() {
		try {
			connectDB();
			saveStations();
			savePrices();
			getInfo( true );
		} catch( Exception $e ) {
			getInfo( false );
		}
	}
	function saveStations() {
		global $db;
		mysqli_query( $db, "TRUNCATE TABLE  `it_stations`" );
		global $stationsURL;
		$csv = download( $stationsURL );
		$csv = explode( "\n", $csv );
		for( $i = 2; $i <= count($csv); $i++ ) {
			$a = explode( ";", x($csv[$i]) );
			mysqli_query( $db, "INSERT INTO `it_stations`(`id`, `name`, `adress`, `brand`, `lat`, `lng`) VALUES ( \"$a[0]\", \"$a[4]\", \"".($a[5]."?".$a[6]." (".$a[7].")")."\", \"$a[2]\", \"$a[8]\", \"$a[9]\" )" ) or die( mysqli_error() );
		}
	}
	function savePrices() {
		global $db;
		mysqli_query( $db, "TRUNCATE TABLE  `it_prices`" );
		global $pricesURL;
		$csv = download( $pricesURL );
		$csv = explode( "\n", $csv );
		for( $i = 2; $i <= count($csv); $i++ ) {
			$a = explode( ";", $csv[$i] );
			mysqli_query( $db, "INSERT INTO `it_prices`(`id`, `type`, `price`, `self`, `date`) VALUES ( \"$a[0]\", \"$a[1]\", \"$a[2]\", ".($a[3]==0?"false":"true").", \"$a[4]\" )" ) or die( mysqli_error() );
			
		}
	}
	function download( $url ) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$data = curl_exec($ch);
		curl_close($ch);
		return $data;
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
		$ret = array();
		$q = mysqli_query( $db, "SELECT * FROM `it_stations`" );
		while( ($station=mysqli_fetch_assoc( $q))!=null ) {
			$station["distance"] = ceil(getDistance( (double)$station["lat"], (double)$station["lng"], (double)$lat, (double)$lng )*1000);
			if( $station["distance"] < $rad*1000 ) {
				$station["prices"] = getPrices( $station["id"] );
				$ret[] = $station;
			}
		}
		return $ret;
	}
	function getStation( $id ) {
		global $db;
		$o = mysqli_fetch_assoc( mysqli_query($db, "SELECT * FROM `it_stations` WHERE `id` Like \"$id\" ") );
		$o["prices"] = getPrices( $id );
		return $o;
	}
	function getPrices( $id ) {
		global $db;
		$ret = array();
		$q = mysqli_query( $db, "SELECT * FROM `it_prices` WHERE `id` Like \"$id\"" );
		while( ($price=mysqli_fetch_assoc( $q))!=null ) {
			$price["self"] = $price["self"]==1;
			$ret[] = $price;
		}
		return $ret;
	}
	function x( $s ) {
		return str_replace( "\"","\\\"",$s );
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
		global $db;
		$lp = mysqli_fetch_assoc( mysqli_query($db, "SELECT COUNT(*) As length FROM `it_prices` WHERE 1" ) );
		$lp = $lp["length"];
		$ls = mysqli_fetch_assoc( mysqli_query($db, "SELECT COUNT(*) As length FROM `it_stations` WHERE 1" ) );
		$ls = $ls["length"];
		$s = $s&&($lp>0)&&($ls>0);
		mail('lukasnagel99@gmail.com', 'Cron Job: '.($s?"Succesfull":"Some Kinda Broke"), "Stationen: $ls | Preise: $lp" );
	}
	
	
	$stationsURL = "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv";
	$pricesURL = "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv";
	include "../index.php";
	include '../db.php';
	main();
?>
