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
		mysql_query( "TRUNCATE TABLE  `stations`" );
		global $stationsURL;
		$csv = download( $stationsURL );
		$csv = explode( "\n", $csv );
		for( $i = 2; $i <= count($csv); $i++ ) {
			$a = explode( ";", x($csv[$i]) );
			mysql_query( "INSERT INTO `stations`(`id`, `name`, `adress`, `brand`, `lat`, `lng`) VALUES ( \"$a[0]\", \"$a[4]\", \"".($a[5]."?".$a[6]." (".$a[7].")")."\", \"$a[2]\", \"$a[8]\", \"$a[9]\" )" ) or die( mysql_error() );
		}
	}
	function savePrices() {
		mysql_query( "TRUNCATE TABLE  `prices`" );
		global $pricesURL;
		$csv = download( $pricesURL );
		$csv = explode( "\n", $csv );
		for( $i = 2; $i <= count($csv); $i++ ) {
			$a = explode( ";", $csv[$i] );
			mysql_query( "INSERT INTO `prices`(`id`, `type`, `price`, `self`, `date`) VALUES ( \"$a[0]\", \"$a[1]\", \"$a[2]\", ".($a[3]==0?"false":"true").", \"$a[4]\" )" ) or die( mysql_error() );
			
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
		$ret = array();
		$q = mysql_query( "SELECT * FROM `stations`" );
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
		$o = mysql_fetch_assoc( mysql_query("SELECT * FROM `stations` WHERE `id` Like \"$id\" ") );
		$o["prices"] = getPrices( $id );
		return $o;
	}
	function getPrices( $id ) {
		$ret = array();
		$q = mysql_query( "SELECT * FROM `prices` WHERE `id` Like \"$id\"" );
		while( ($price=mysql_fetch_assoc($q))!=null ) {
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
				cron();
			break;
			case "info":
				connectDB();
				getInfo( true );
			break;
			default: header( "Location: https://github.com/xXSparkeyy/harbour-spritradar" );
		}
	}
	function getInfo( $s ) {
		$lp = mysql_fetch_assoc( mysql_query("SELECT COUNT(*) As length FROM `prices` WHERE 1" ) )["length"];
		$ls = mysql_fetch_assoc( mysql_query("SELECT COUNT(*) As length FROM `stations` WHERE 1" ) )["length"];
		$s = $s&&($lp>0)&&($ls>0);
		mail('@.com', 'Cron Job: '.($s?"Succesfull":"Some Kinda Broke"), "Stationen: $ls | Preise: $lp" );
	}
	
	
	$stationsURL = "http://www.sviluppoeconomico.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv";
	$pricesURL = "http://www.sviluppoeconomico.gov.it/images/exportCSV/prezzo_alle_8.csv";
	include 'db.php';
	main();
?>
