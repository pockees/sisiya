<?php

### a class for getting a TMX XML file contents as key,value pair resource array
class ResourceBundleTMX {
	# PHP 5 uses private, protected and public. PHP 4 requires var before variable names;
	# There is a difference in constructor/destructor names between version 4 and 5 of PHP
	# PHP4 does not have destructor 
	# In PHP 5 members of a class without a public,private or protected are public

	# for PHP 4
	var $key;
	var $value;
	var $currentLanguage;
	var $language;
	var $resource;
	var $segFlag;
	
	# for PHP 5
/*
	private $key;
	private $value;
	private $currentLanguage;
	private $language;
	private $resource;
	private $segFlag;
*/
	# Constructor
	# PHP 4
	function ResourceBundleTMX($tmxFile,$language) 
	# PHP 5
	#public function __constructor($tmxFile,$language) 
	{
		$this->key="";
		$this->value="";
		$this->currentLanguage="";

		$this->resource=array();
		$this->language=strtoupper($language);
	 	$this->segFlag=false;
		
			
		$this->parser=xml_parser_create();
		xml_set_object($this->parser,$this);
		// disable case-folding for this XML parser
		xml_parser_set_option($this->parser,XML_OPTION_CASE_FOLDING,0);
		xml_set_element_handler($this->parser,"startHandler","endHandler");
		xml_set_character_data_handler($this->parser,"segHandler");
		if(!xml_parse($this->parser,file_get_contents($tmxFile)))
			die(sprintf("ResourceBundleTMX:: XML error: %s at line %d",xml_error_string(xml_get_error_code($this->parser)),xml_get_current_line_number($this->parser)));
		xml_parser_free($this->parser);
	}
	
	# Destructor
	# PHP 5
/*
	public function __destruct() 
	{
		$resource=array();
	}
*/
	# PHP 5
	function endHandler($parser,$name) 
	# PHP 5
	#private function endHandler($parser,$name) 
	{
		switch(strtolower($name)) {
			case 'tu': 
				$this->key="";
				break;
			case 'tuv':
				$this->currentLanguage="";
				break;
			case 'seg':
				$this->segFlag=false;
				if(!empty($this->value) OR !array_key_exists($this->key,$this->resource))
					$this->resource[$this->key]=$this->value; 
				break;
			default:
				break;
		}
	}

	function getResource() 
	{
		return $this->resource;
	}
	
	# PHP 4
	function segHandler($parser,$data) 
	# PHP 5
	#private function segHandler($parser,$data) 
	{
		if($this->segFlag AND (strlen($this->key) > 0) AND (strlen($this->currentLanguage) > 0)) {
			if(strcasecmp($this->currentLanguage,$this->language) == 0)
				$this->value .= $data;
		}
	}

	
	# PHP 4
	function startHandler($parser,$name,$attribs) 
	# PHP5 
	#private function startHandler($parser,$name,$attribs) 
	{
		switch(strtolower($name)) {
			case 'tu': 
				if(array_key_exists('tuid',$attribs))
					$this->key=$attribs['tuid'];
				break;
			case 'tuv': 
				if(array_key_exists('xml:lang',$attribs))
					$this->currentLanguage=$attribs['xml:lang'];
				break;
			case 'seg':
				$this->segFlag=true;
				$this->value="";
				break;
			default: 
				break;
		}
	}
} 
?>
