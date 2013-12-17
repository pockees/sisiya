	/************************************************************************************************************
	(C) www.dhtmlgoodies.com, November 2005
	
	This is a script from www.dhtmlgoodies.com. You will find this and a lot of other scripts at our website.	
	
	Terms of use:
	You are free to use this script as long as the copyright message is kept intact. However, you may not
	redistribute, sell or repost it without our permission.
	
	Thank you!
	
	www.dhtmlgoodies.com
	Alf Magne Kalleland
	
	************************************************************************************************************/
		
	var slideTimeBetweenSteps = 30;	// General speed variable (Lower = slower)
	
	
	var scrollingContainer = false;
	var scrollingContent = false;
	var containerHeight;
	var contentHeight;	
	
	var contentObjects = new Array();
	var originalslideSpeed = false;
	function slideContent(containerId)
	{
		var topPos = contentObjects[containerId]['objRef'].style.top.replace(/[^\-0-9]/g,'');
		topPos = topPos - contentObjects[containerId]['slideSpeed'];
		if(topPos/1 + contentObjects[containerId]['contentHeight']/1<0)topPos = contentObjects[containerId]['containerHeight'];
		contentObjects[containerId]['objRef'].style.top = topPos + 'px';
		setTimeout('slideContent("' + containerId + '")',slideTimeBetweenSteps);
		
	}
	
	function stopSliding()
	{
		var containerId = this.id;
		contentObjects[containerId]['slideSpeed'] = 0;	
	}
	
	function restartSliding()
	{
		var containerId = this.id;
		contentObjects[containerId]['slideSpeed'] = contentObjects[containerId]['originalSpeed'];
		
	}
	function initSlidingContent(containerId,slideSpeed)
	{
		scrollingContainer = document.getElementById(containerId);
		scrollingContent = scrollingContainer.getElementsByTagName('DIV')[0];
		
		scrollingContainer.style.position = 'relative';
		scrollingContainer.style.overflow = 'hidden';
		scrollingContent.style.position = 'relative';
		
		scrollingContainer.onmouseover = stopSliding;
		scrollingContainer.onmouseout = restartSliding;
		
		originalslideSpeed = slideSpeed;
		
		scrollingContent.style.top = '0px';
		
		contentObjects[containerId] = new Array();
		contentObjects[containerId]['objRef'] = scrollingContent;
		contentObjects[containerId]['contentHeight'] = scrollingContent.offsetHeight;
		contentObjects[containerId]['containerHeight'] = scrollingContainer.clientHeight;
		contentObjects[containerId]['slideSpeed'] = slideSpeed;
		contentObjects[containerId]['originalSpeed'] = slideSpeed;
		
		slideContent(containerId);
		
	}