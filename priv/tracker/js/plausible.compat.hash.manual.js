!function(){"use strict";var t,e,n,a=window.location,o=window.document,r=o.getElementById("plausible"),l=r.getAttribute("data-api")||(t=r.src.split("/"),e=t[0],n=t[2],e+"//"+n+"/api/event");function w(t){console.warn("Ignoring Event: "+t)}function i(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(a.hostname)||"file:"===a.protocol)return w("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return w("localStorage flag")}catch(t){}var n={};n.n=t,n.u=e&&e.u?e.u:a.href,n.d=r.getAttribute("data-domain"),n.r=o.referrer||null,n.w=window.screen.width||window.innerWidth,e&&e.meta&&(n.m=JSON.stringify(e.meta)),e&&e.props&&(n.p=e.props),n.h=1;var i=new XMLHttpRequest;i.open("POST",l,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(n)),i.onreadystatechange=function(){4===i.readyState&&e&&e.callback&&e.callback()}}}var s=window.plausible&&window.plausible.q||[];window.plausible=i;for(var d=0;d<s.length;d++)i.apply(this,s[d])}();