!function(){"use strict";var t,e,n,o=window.location,l=window.document,s=l.getElementById("plausible"),u=s.getAttribute("data-api")||(t=s.src.split("/"),e=t[0],n=t[2],e+"//"+n+"/api/event");function w(t){console.warn("Ignoring Event: "+t)}function a(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return w("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return w("localStorage flag")}catch(t){}var n={};n.n=t,n.u=e&&e.u?e.u:o.href,n.d=s.getAttribute("data-domain"),n.r=l.referrer||null,n.w=window.innerWidth,e&&e.meta&&(n.m=JSON.stringify(e.meta)),e&&e.props&&(n.p=e.props);var a=s.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),i=n.p||{};a.forEach(function(t){var e=t.replace("event-",""),n=s.getAttribute(t);i[e]=i[e]||n}),n.p=i;var r=new XMLHttpRequest;r.open("POST",u,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(n)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var i=window.plausible&&window.plausible.q||[];window.plausible=a;for(var r=0;r<i.length;r++)a.apply(this,i[r])}();