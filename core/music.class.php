<?php

class music {

	private $pdo;

	function __construct($db) {
		$this->pdo = $db;
	}
	
	function get_first_trackinfo($genre) {
		return $this->pdo->query_single_row("SELECT * FROM `jrp2_tracklist` WHERE `genre` LIKE ? ORDER BY `random` LIMIT 1", array($genre));
	}
	
	function get_next_trackinfo($genre, $after) {
		return $this->pdo->query_single_row("SELECT * FROM `jrp2_tracklist` WHERE `genre` LIKE ? AND `random` > ? ORDER BY `random` LIMIT 1", array($genre, $after));
	}
}

