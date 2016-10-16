<?php
class database {

	private $pdo, $queries = 0;

	function __construct($config) {
		$this->pdo = new PDO (
			sprintf('mysql:host=%s;dbname=%s', $config['hostname'], $config['database']), 
			$config['login'], 
			$config['password']
		);
		if($this->pdo) {
			$this->pdo->query("SET NAMES 'utf8'");
			++$this->queries;
			return $this->pdo;
		}
	}

	public function disconnect() {
		$this->pdo = null;
	}

	public function query($query, $params = array(), $arr = null) {
		$res = $this->pdo->prepare($query);
		if($res) {
			$res->execute($params);
			++$this->queries;
			return $res->fetchAll($arr ? PDO::FETCH_NUM : PDO::FETCH_ASSOC);
		} else return null;
	}
	
	public function query_single_col($query, $params = array()) {
		$res = $this->pdo->prepare($query);
		if($res) {
			$res->execute($params);
			++$this->queries;
			$val = $res->fetch(PDO::FETCH_NUM);
			return $val[0];
		} else return null;
	}

	public function query_single_row($query, $params = array(), $arr = null) {
		$res = $this->pdo->prepare($query);
		if($res) {
			++$this->queries;
			$res->execute($params);
			$val = $res->fetch($arr ? PDO::FETCH_NUM : PDO::FETCH_ASSOC);
			return $val;
		} else return null;
	}

}
?>