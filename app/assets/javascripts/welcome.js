//welcome.js

function SetHome( obj )
{
	var oNode = obj;

	alert( "this.interHTML: " + oNode.interHTML + 
			"\nthis.nodeName: " + oNode.nodeName +
			"\nthis.nodeValue: " + oNode.nodeValue +
			"\nthis.nodeType: " + oNode.nodeType +
			"\nthis.className: " + oNode.className +
			"\nthis.href: " + oNode.href +
			"\nthis.style.behavior: " + oNode.style.behavior );

}

function initNode()
{
	oVideo0 = document.getElementById("video_0");
	// oVideo0.height = 500;

	// alert("oVideo0.clientWidth: " + oVideo0.clientWidth + " !\noVideo0.clientHeight: " + oVideo0.clientHeight + " !\n");
}

var oVideo0 = null;

// setTimeout(initNode, 100);
