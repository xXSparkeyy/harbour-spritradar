<?php
	/*
	SELECT name, ( 3959 * acos( cos( radians($lat) ) * cos( radians( lat ) ) * cos( radians(lng) - radians($lng)) + sin(radians($lat)) * sin( radians(lat)))) AS distance FROM locations WHERE active = 1 HAVING distance < 10 ORDER BY distance;
		 */	$types = array('GPR', 'G98', 'GOA', 'NGO', 'GOB', 'GOC', 'BIO', 'G95', 'BIE', 'GLP', 'GNC');
	function downloadFiles() {
		download();
	}
	function download() {
		$url = "https://donnees.roulez-eco.fr/opendata/instantane";
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$data = curl_exec($ch);
		curl_close($ch);
		$f = fopen( "tmp/prxcbrnts.zip", "w+" );
		fwrite( $f, $data );
		fclose( $f );
	}
	function parseFiles() {
		global $db;
		global $types;
		mysqli_query( $db, "TRUNCATE TABLE  `fr_stations`" );
		parseFile();
	}
	function parseFile() {
		global $db;
		$zip = zip_open( "tmp/prxcbrnts.zip" );
		$entry = zip_read( $zip );
		zip_entry_open( $zip, $entry, "r" );
		$xml = zip_entry_read( $entry, zip_entry_filesize( $entry ) );
		zip_entry_close( $entry );
		zip_close( $zip );
		$sax = xml_parser_create();
		xml_parser_set_option($sax, XML_OPTION_CASE_FOLDING, false);
		xml_parser_set_option($sax, XML_OPTION_SKIP_WHITE, true);
		xml_set_element_handler($sax, 'sax_start', 'sax_end');
		xml_set_character_data_handler($sax, 'sax_cdata');
		xml_parse($sax, $xml, true);
		xml_parser_free($sax);		
	}
	function sax_start($sax, $tag, $attr) {
		if( $tag == "pdv") {
			newEntry( $attr );
			return;
		}
		setCurrentTag( $tag, $attr );
	}
	function sax_end($sax, $tag) {
		global $entry;
		if( $tag == "pdv") {
			saveEntry();
		}
		if( $tag == "service") {
			$entry["services"][] = $entry["cservice"];
			$entry["cservice"] = "";
		}
		setCurrentTag( "" );
	}
	function sax_cdata($sax, $data) {
		global $entry;
	  switch( getCurrentTag() ) {
	  	case "adresse": $entry["adresse"] .= $data; break;
	  	case "ville": $entry["ville"] .= $data; break;
	  	case "service": $entry["cservice"] .= $data; break;
	  }
	}
	$entry = []; $currentTag = "";
	function newEntry( $args ) {
		global $entry;
		$entry = array(
			"id"=>$args["id"],
			"latitude"=>$args["latitude"]*1/100000,
			"longitude"=>$args["longitude"]*1/100000,
			"adresse"=>"", "ville"=>"", "cservice"=>"", "services"=>[],
			"prices"=>[], "openingtimes"=>[], "distance"=>"DiStAnCe"
		);
	}
	function saveEntry() {
		global $entry, $db;
		$cont = addslashes(json_encode( $entry )); mysqli_query( $db, "INSERT INTO `fr_stations`(`id`, `content`, `lat`, `lng` ) VALUES ( \"{$entry['id']}\", \"$cont\", \"{$entry['latitude']}\", \"{$entry['longitude']}\" )" ) or die( mysqli_error($db) );
	}
	function setCurrentTag( $tag, $arg=false ) {
		global $entry;
		global $currentTag; $currentTag = $tag;
		if( $tag == "ouverture") {
			$entry["openingtimes"][] = array( "from"=>$arg["debut"], "to"=>$arg["fin"], "except"=>$arg["saufjour"] );
		}
		if( $tag == "prix") {
			$entry["prices"][] = array( "id"=>$arg["nom"], "updated"=>$arg["maj"], "price"=>$arg["valeur"] );
		}
	}
	function getCurrentTag() {
		global $currentTag; return $currentTag;
	}
	function clearFiles() {
		global $types;
		foreach( $types as $name ) { unlink( "tmp/$name.zip" ); }
	}
	
	function getStations($lat, $lng, $rad) {
		global $db;
		$first = true;
		$q = mysqli_query( $db, "SELECT `content`, ( 3959 * acos( cos( radians($lat) ) * cos( radians( lat ) ) * cos( radians(lng) - radians($lng)) + sin(radians($lat)) * sin( radians(lat)))) AS distance FROM `fr_stations` HAVING `distance` < $rad" );
		echo "[";
		while( ($station=mysqli_fetch_assoc($q))!=null ) {
			if( !$first ) echo ", ";
			echo str_replace( "DiStAnCe", $station["distance"], stripslashes($station["content"]) );
			$first = false;
		}
		echo "]";
	}
	function getStation( $id ) {
		global $db;
		$q = mysqli_query($db, "SELECT `content` FROM `fr_stations` WHERE `id` Like $id ");
		$o = mysqli_fetch_assoc( $q );
		echo $o["content"];
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
				echo getStations( $_GET["lat"], $_GET["lng"], $_GET["radius"] );
			break;
			case "station":
				connectDB();
				getStation( $_GET["id"] );
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
		$ls = mysqli_fetch_assoc( mysqli_query($db, "SELECT COUNT(*) As length FROM `fr_stations` WHERE 1" ) );
		$ls = $ls["length"];
		$s = $s&&($ls>0);
        if($sendmail) mail('lukasnagel99@gmail.com', '[FR] Cron Job: '.($s?"Succesfull":"Some Kinda Broke"), "Stationen: $ls" );
		else {
		    echo "{ 'stations': $ls }";
		}
	}
	include "../index.php";
	include '../db.php';
	main();
?>
