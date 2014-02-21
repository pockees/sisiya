<?php
/*
    Copyright (C) 2003 - __YEAR__ Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

*/
class HTMLDocument {
	protected $html;		# the HTML code
	protected $doctype;		# contents of <!DOCTYPE XXX>, the XXX part of DOCTYPE
	protected $bodyTag;		# contents of <body XXX>, the XXX part of body
	protected $body;		# contents of <body></body>
	protected $headTag;		# contents of <head></head>
	protected $htmlTag;		# contents of <html XXX>, the XXX part. Example: <html xmlns="http://www.w3.org/1999/xhtml>
	protected $tite;		# the title of the document

	function HTMLDocument()
	{
		$this->html='';
		$this->doctype='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'."\n";
		$this->headTag='';
		$this->htmlTag="<html>\n";
		$this->bodyTag="<body>\n";
		$this->body='';
		$this->title='';
	}
	
	private function create()
	{	
		$this->html=$this->doctype;
		### add the html tag
		$this->html.=$this->htmlTag;
		### add the head tag
		$this->html.="<head>\n";
		$this->html.=$this->headTag;
		$this->html.=$this->title;
		$this->html.="</head>\n";
		### add the body
		$this->html.=$this->bodyTag;
		$this->html.=$this->body;
		$this->html.="</body>\n";
		### close the html tag
		$this->html.="</html>\n";
	}

	# displays the HTML code
	function display()
	{
		$this->create();
		echo $this->html;
		
	}

	# retrievs the HTML source code
	function get()
	{
		$this->create();
		return $this->html;
		
	}

	# sets the body tag 
	function setBodyTag($str)
	{
		$this->bodyTag='<body '.$str.">\n";
	}

	# sets the document type 
	function setDoctype($str)
	{
		$this->doctype='<!DOCTYPE '.$str.">\n";
	}

	# used for adding meta, link etc in the head section of a HTML document
	function addHeadContent($str)
	{
		$this->headTag.=$str."\n";
	}

	# adds content in the body
	function addContent($str)       
	{
		$this->body.=$str."\n";
	}
	# sets the HTML tag 
	# the xmlns="http://www.w3.org/1999/xhtml" part of <html xmlns="http://www.w3.org/1999/xhtml"> tag
	function setHTMLTag($str)
	{
		$this->htmlTag="<html>\n";
		if($str != '')
			$this->htmlTag='<html '.$str.">\n";
	}

	# sets the document title
	function setTitle($str)
	{
		$this->title='<title>'.$str."</title>\n";
	}
}
