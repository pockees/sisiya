For installation and configuration instructions please read the INSTALL file.


===============================================================================================================================
Various statuses:
===============================================================================================================================
------------------------+-----------------------+-----------------------------------------------------------------
|  status order no	|	statusid	|     Color and symbol                                            |
------------------------+-----------------------+-----------------------------------------------------------------
| 0) info    		|	2^0 = 1		|	I on blue
| 1) ok			|	2^1 = 2		|	Check on green
| 2) warning		|	2^2 = 4		|	! on yellow
| 3) error		|	2^3 = 8		|	! on red
| 4) noreport		|	2^4 = 16	|	? on the worst color of (error, warning, ok, info)
| 5) unavailable	|	2^5 = 32	|	x on the worst color of (error, warning, ok, info)
| 6) mwarning		|	2^6 = 64	|	! on yellow with a maintanence sign
| 7) merror		|	2^7 = 128	|	error with maintanence
| 8) mnoreport		|	2^8 = 256	|	no report  with maintanence
| 9) munavailable	|	2^9 = 512	|	unavailable with maintanence
------------------------+-----------------------+-----------------------------------------------------------------

mwarning 	= 16 * warning 		= 16 * 4 	= 64
merror   	= 16 * error   		= 16 * 8 	= 128
mnoreport	= 16 * noreport 	= 16 * 16 	= 256
munavailable	= 16 * unavailable 	= 16 * 32	= 512

Sum of all (n=9) possible statuses = 2^(n+1) - 1 = 2^(9+1) - 1 = 2^10 - 1 = 1024 -1 = 1023

------------------------------------
t = total of uniq statusid's
------------------------------------
	info		: t  =  1		=> I on blue				=> Info.png 
 	ok 		: 1  <  t < 4		=> Check on green			=> Ok.png
	warning		: 4  <= t < 8		=> ! on yellow				=> Warning.png
	error		: 8  <= t < 16		=> ! on red				=> Error.png
	noreport	: 16 <= t < 32		=> ? on plain color			=> Noreport.png
			: (t-16) < 4		=> ? on green				=> NoreportGreen.png
			: (t-16) < 8		=> ? on yellow				=> NoreportYellow.png
			: (t-16) < 16		=> ? on error				=> NoreportRed.png 
	unavailable	: 32 <= t < 64		=> x on plain color			=> Unavailable.png
			: (t-32) < 4		=> x on green				=> UnavailableGreen.png
			: (t-32) < 8		=> x on yellow				=> UnavailableYellow.png
			: (t-32) < 16		=> x on error				=> UnavailableRed.png
	mwarning	: 64 <= t < 128		=> ! on yellow with maintanance sign	=> MWarning.png
			: (t-64) < 4		=> mwarning on green			=> MWarningGreen.png
			: (t-64) < 8		=> mwarning on yellow			=> MWarning.png
			: (t-64) < 16		=> mwarning on red			=> MWarningRed.png
	merror		: 128 <= t < 256	=> ! on red with maintanance sign	=> MError.png
			: (t-128) < 4		=> merror on green			=> MErrorGreen.png
			: (t-128) < 8		=> merror on yellow			=> MErrorYellow.png
			: (t-128) < 16		=> merror on red			=> MError.png
	mnoreport	: 256 <= t < 512	=> ? on red with maintanance sign	=> MNoreport.png
			: (t-256) < 4		=> mnoreport on green			=> MNoreportGreen.png
			: (t-256) < 8		=> mnoreport on yellow			=> MNoreportYellow.png
			: (t-256) < 16		=> mnoreport on red			=> MNoreportError.png
	munavailable	: 512 <= t < 1024	=> x on red with maintanance sign	=> MUnavailable.png
			: (t-512) < 4		=> munavailable on green		=> MUnavailableGreen.png
			: (t-512) < 8		=> munavailable on yellow		=> MUnavailableYellow.png
			: (t-512) < 16		=> munavailable on red			=> MUnavailableRed.png



info, ok, warning and error are known, measarable statuses

no report 	: service message expired
unavailable	: reomte checks like oracle connection or http connection and the connection could not be established
		  This case is very similar to an error, but the remote check does not know for sure wheter the service is up or not.

===============================================================================================================================
Trouble ticket system:
===============================================================================================================================

- Every statusid must have a corresponding statusid with a sign showing that some is working on this subject:
	warning 	-> warning with spacial sign 		(xwarning)
	error		-> error with spacial sign		(xerror)
	no report 	-> no report with spacial sign		(xnoreport)
	unavailable 	-> unavailable with spacial sign	(xunavailable)

	
===============================================================================================================================
Graphics/statistics
===============================================================================================================================
- The charts must indicate the different statuses

===============================================================================================================================
RSS, SisIYA_icon etc
===============================================================================================================================
- These applications must read the statusid directly from the systemstatus table, without any further logic
===============================================================================================================================


Examples:

A system with:
- infos and okeys 						-> ok
- infos, okeys and warnings					-> warning 
- infos, okeys, warnings and errors				-> error
- all statusX							-> statusX
The following are: ????????????????????????
- infos, okeys and at least one no report			-> some with no reports, but others okey		=> ? on green     = 10
- infos, okeys and at least one unavailable			-> some with unavailable, but others okey		=> x on green     = 18
- infos, okeys,warnigs and at least one no report		-> some with no report, but others with warnings	=> ? on yellow    = 12
- infos, okeys,warnigs and at least one unavailable		-> some with unavailable, but others with warnings	=> x on yellow    = 20
- infos, okeys, warnigs, errors and at least one no report	-> some with no report, but others with errors		=> ? on red       = 40
- infos, okeys, warnigs, errors and at least one unavailable	-> some with unavailable, but others with errors	=> x on red       = 48
- all at ones							->  		=> x? on worst of (error,warning,ok,info) = (sum of all) =63
- all - info		= 62
- all - info - ok	= 60
=====> sum of uniq statusid's
	1) systemstatus
		sum of 2^statusid
		select sum(pow(2,statusid)) from (select statusid from systemstatus group by statusid) w
	2) systemservicestatus
		sum of 2^statusid
		select sum(pow(2,statusid)) from (select statusid from systemservicestatus group by statusid) w

And with the trouble ticket system all the above symbols with a spacial sign
indicating that some is working on the system.

===============================================================================================================================
