//welcome.js

function initURLs()
{
	for (var i = aURLs.length - 1; i >= 0; i--) {
		aURLs[i] = "/images/slides_ad_" + i + ".jpg";
	}
	// alert("aURLs[5]: " + aURLs[5] + " !");
}

function initNode_background()
{
	aSlidesNodes = document.getElementsByClassName("slides");
	oSlides = aSlidesNodes[0];
}

function initNode()
{
	aSlideNodes = document.getElementsByClassName("slide");
	oSlide = aSlideNodes[0];
	// alert("oSlide: "+ oSlide + " !");

	oCanvas = document.getElementById("canvas");
	// alert("oCanvas.clientWidth: "+ oCanvas.clientWidth + " !");

	oImg0 = document.getElementById("img0");
	oImg1 = document.getElementById("img1");
	// oImg0.style.left = "0px";
	// oImg1.style.left = "1024px";
	// alert("oSlides: "+ oSlides + " !");
	// alert("oImg0: " + oImg0 + "!");
	// alert("oImg1: " + oImg1 + "!");
	iSlideScroll = oSlide.clientWidth;
	// alert("iSlideScroll: "+ iSlideScroll + " !");
}

function changeSlide_backgroud()
{
	// alert("changeSlide is executed !");
	if (aURLs.length == iURL) 
	{
		iURL = 0;
	}

	// alert("changeSlide is executed !\n\
	// 	iURL: " + iURL + "!\n\
	// 	oSlides: " + oSlides + "!\n\
	// 	aURLs: " + aURLs + "!\n\
	// 	oSlides.style.background: " + oSlides.style.background + "!");

	// alert("oSlides: "+ oSlides + " !");

	// alert("aSlidesNodes[0]: "+ aSlidesNodes[0] + " !");

	oSlides.style.background = "url(\"" + aURLs[iURL] + "\")";
	oSlides.style.backgroundSize = "1024px 200px";

	iURL++;

}

function scrollSlide()
{	
	
	// oImg0.scrollLeft++;
	// oImg1.scrollLeft++;
	// oSlide.scrollLeft+=(oSlide.width/2);
	// oCanvas.scrollLeft = oCanvas.scrollLeft + 200;
	oSlide.scrollLeft = oSlide.scrollLeft + (oSlide.clientWidth/5);

	// alert("scrollSlide is executed !\noSlide.scrollLeft: " + oSlide.scrollLeft + "\noSlide.clientWidth: " + oSlide.clientWidth + "!");

	// alert("scrollSlide is executed !\n\
	// 	oSlide.scrollLeft: " + oSlide.scrollLeft + "!");

	if ( (oCanvas.clientWidth - oSlide.clientWidth) <= oSlide.scrollLeft) 
	{
		clearInterval(iScrollSlide);

		var oTemp = oCanvas.firstElementChild;
		// alert("firstChild.id: "+ oTemp.id + " !");
		oCanvas.removeChild(oTemp);
		if (aURLs.length == iURL) 
		{
			iURL = 0;
		}
		oTemp.src = aURLs[iURL];
		// alert("oTemp.src: "+ oTemp.src + " !");
		iURL++;
		oCanvas.appendChild(oTemp);
		// oTemp.style.position = "absolute";
		// oTemp.style.top = "0px";
		// oTemp.style.left = "100px";
		// oSlide.firstElementChild.style.top = "0px";
		// oSlide.firstElementChild.style.left = "-100px";

		// oSlide.removeChild(oImg0);
		// oSlide.appendChild(oImg0);
		// iSlideScroll += oSlide.scrollLeft;
		// alert("oCanvas.childElementCount: " + oCanvas.childElementCount + " !");
		// alert("oCanvas.clientWidth: " + oCanvas.clientWidth + " !");
		// alert("oSlide.scrollLeft: " + oSlide.scrollLeft + "\noSlide.scrollWidth: " + oSlide.scrollWidth + " !");
		oSlide.scrollLeft = 0;
	}
}

function scrollSlide_oSlide()
{	
	// var iLeft = 0;
	// oImg0.style.left = oImg0.style.left - ();
	alert("scrollSlide is executed !\noSlide.scrollLeft: " + oSlide.scrollLeft + "\noSlide.clientWidth: " + oSlide.clientWidth + "!");
	// oImg0.scrollLeft++;
	// oImg1.scrollLeft++;
	// oSlide.scrollLeft+=(oSlide.width/2);
	oSlide.scrollLeft = oSlide.scrollLeft + 200;

	// alert("scrollSlide is executed !\n\
	// 	oSlide.scrollLeft: " + oSlide.scrollLeft + "!");

	if ( iSlideScroll <= oSlide.scrollLeft) 
	{
		clearInterval(iScrollSlide);

		var oTemp = oSlide.firstElementChild;
		alert("firstChild.id: "+ oTemp.id + " !");
		oSlide.removeChild(oTemp);
		// oSlide.appendChild(oTemp);
		// oTemp.style.position = "absolute";
		// oTemp.style.top = "0px";
		// oTemp.style.left = "100px";
		oSlide.firstElementChild.style.top = "0px";
		oSlide.firstElementChild.style.left = "-100px";

		// oSlide.removeChild(oImg0);
		// oSlide.appendChild(oImg0);
		iSlideScroll += oSlide.scrollLeft;
		alert("oSlide.childElementCount: " + oSlide.childElementCount + " !");
	}
}

function scrollSlide_scrollLeft()
{	
	// alert("scrollSlide is executed !");
	// oImg0.scrollLeft++;
	// oImg1.scrollLeft++;
	// oSlide.scrollLeft+=(oSlide.width/2);
	oSlide.scrollLeft = oSlide.scrollLeft + (oSlide.clientWidth/5);

	// alert("scrollSlide is executed !\n\
	// 	oSlide.scrollLeft: " + oSlide.scrollLeft + "!");

	if (oSlide.clientWidth <= oSlide.scrollLeft) 
	{
		clearInterval(iScrollSlideTimer);
	}
}

function changeSlide()
{
	var sLeft = "";
	// alert("oImg0.style.left: " + oImg0.style.left + "!");
	// alert("changeSlide is executed !");
	// alert("oImg0.style.left: " + oImg0.style.left + "!");
	// alert("oImg1.style.left: " + oImg1.style.left + "!");
	iScrollSlide = setInterval(scrollSlide, iSpeed);
	// alert("oSlide: " + oSlide + "!");
	// alert("oSlide.clientWidth: " + oSlide.clientWidth + "!");
	// alert("oSlide: " + oSlide + "!");
	// // oImg0.style.left = oImg1.style.left;
	// sLeft = oImg0.style.left;
	// oImg0.style.left = oImg1.style.left;
	// oImg1.style.left = sLeft;
	// alert("oImg0.style.left: " + oImg0.style.left + "!");
	// alert("oImg1.style.left: " + oImg1.style.left + "!");
	// oImg0.style.left = "50%";
	// oSlide.insertBefore(oImg1, oImg0);
}

function changeSlide_test()
{
	alert("changeSlide is executed !");
}

function displayMenu(li)
{
	var oUl = li.getElementsByTagName("ul")[0];
	// alert("oUl: " + oUl + " !");
	oUl.style.display = "block";
}

function hideMenu(li)
{
	var oUl = li.getElementsByTagName("ul")[0];
	oUl.style.display = "none";
}

var aURLs = new Array(6);
var iURL = 2;

var aSlidesNodes = null;
var oSlides = null;
var aSlideNodes = null;
var oSlide = null;
var iSlideScroll = 0;

var oCanvas = null;
var oImg0 = null;
var oImg1 = null;
var iSpeed = 200;
var iScrollSlideTimer = 0;

initURLs();

var iDelay = setTimeout("initNode()", 100);
// var iTimer = setTimeout("changeSlide()", 1000);

var iTimer = setInterval("changeSlide()", 5000);

