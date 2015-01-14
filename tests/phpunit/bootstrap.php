<?php
global $CONFIG;
$root = dirname(dirname(dirname(__FILE__)));

define('__MINDS_ROOT__', $root);

require_once($root.'/vendor/autoload.php');

$minds = new minds\core\minds();
$minds->loadConfigs();
$minds->loadLegacy();

@mkdir('/tmp/minds_test/', 777);
$CONFIG->dataroot = '/tmp/minds_test/';

//require_once("$engine/settings.php");


require_once(dirname(__FILE__) .'/Minds_PHPUnit_Framework_TestCase.php');

/*spl_autoload_register(function($class){
	
});*/

date_default_timezone_set('America/Los_Angeles');

error_reporting(E_ALL | E_STRICT);

/**
 * Check to see if we are installed. If not, install
 */
try{
	require_once($root .'/install/ElggInstaller.php');
	$db = new Minds\Core\Data\Call(null, 'minds_test_phpcassa', array('localhost'));
	if($db->keyspaceExists()){
		$db->dropKeyspace(true);
	}
	$db->createKeyspace();
	$db->installSchema();
	
	//bootstrap the cassandra config
	$CONFIG->cassandra = (object) array( 'servers'=> array('localhost'), 'keyspace'=>'minds_test_phpcassa');
	$CONFIG->default_access = 2; //public access

	$site = new ElggSite();
	$site->name = 'Minds';
	$site_guid = $site->save();
	
	// bootstrap site info
	$CONFIG->site_guid = $site_guid;
	$CONFIG->site = $site;
}catch(Exception $e){
	var_dump($e);
	exit;
}
