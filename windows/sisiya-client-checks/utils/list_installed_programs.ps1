#    Copyright (C) 2003  - 2010  Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#################################################################################
function Get-InstalledPrograms($computer = '.') {
	$programs_installed = @{};
	$win32_product = @(get-wmiobject -class 'Win32_Product' -computer $computer);
	foreach ($product in $win32_product) {
		$name = $product.Name;
		$version = $product.Version;
		if ($name -ne $null) {
			$programs_installed.$name = $version;
		}
	}
	return $programs_installed;
}

$p=Get_installedPrograms
write-host "Instelled programs:" $p
