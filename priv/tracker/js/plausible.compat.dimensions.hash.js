!function(){"use strict";var t,e,i,o=window.location,l=window.document,s=l.getElementById("plausible"),p=s.getAttribute("data-api")||(t=s.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function c(t){console.warn("Ignoring Event: "+t)}function n(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=s.getAttribute("data-domain"),i.r=l.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var n=s.getAttributeNames().filter(function(t){return"event"===t.substring(0,5)}),a=i.p&&JSON.parse(i.p)||{};n.forEach(function(t){var e=t.replace("event-",""),i=s.getAttribute(t);a[e]=i}),i.p=a,i.h=1;var r=new XMLHttpRequest;r.open("POST",p,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var r,d=0;d<a.length;d++)n.apply(this,a[d]);function w(){r=o.pathname,n("pageview")}window.addEventListener("hashchange",w),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){r||"visible"!==l.visibilityState||w()}):w()}();