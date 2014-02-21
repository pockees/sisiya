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
error_reporting(E_ALL);

$npages=divide_round_up($nrows,$nrecords_per_page);
if($npages > 1) {
	$html='<div class="div_page_numbers">'."\n";
	$start_page=calculate_start_page($start_index,$npages,$nrecords_per_page,$max_pages);
	if($start_page > 1) {
		$html.='<a class="page_number" href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index=0&amp;prev_page_set=1">|&lt;</a>&nbsp;'."\n";
		$html.='<a class="page_number" href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.($start_page-2)*$nrecords_per_page.'&amp;prev_page_set=1">&laquo;</a>&nbsp;'."\n";
	}
	for($i=0;$i<$max_pages;$i++) {
		if(($i + $start_page) > $npages)
			break;
		$html.='<a class="page_number" href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.(($start_page+$i-1)*$nrecords_per_page).'">';
		if($start_index == (($start_page+$i-1)*$nrecords_per_page))
			$html.='<strong>'.($start_page+$i).'</strong>';
		else
			$html.=($start_page+$i);
		$html.='</a>&nbsp;'."\n";
	}
	if(($start_page+$max_pages) <= $npages) {
		$html.='<a class="page_number" href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.(($start_page+$max_pages-1)*$nrecords_per_page).'&amp;next_page_set=1">&raquo;</a>&nbsp;'."\n";
		$html.='<a class="page_number" href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.(($npages-1)*$nrecords_per_page).'&amp;next_page_set=1">&gt;|</a>&nbsp;'."\n";
	}
	$html.='</div> <!-- end of div_page_numbers -->';
	$h->addContent($html);
}
?>
