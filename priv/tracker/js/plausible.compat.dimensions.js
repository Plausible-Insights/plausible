!function(){"use strict";var t,e,i,o=window.location,s=window.document,l=s.getElementById("plausible"),p=l.getAttribute("data-api")||(t=l.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function u(t){console.warn("Ignoring Event: "+t)}function n(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return u("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=l.getAttribute("data-domain"),i.r=s.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var n=l.getAttributeNames().filter(function(t){return"event"===t.substring(0,5)}),a=i.p&&JSON.parse(i.p)||{};n.forEach(function(t){var e=t.replace("event-",""),i=l.getAttribute(t);a[e]=i}),i.p=a;var r=new XMLHttpRequest;r.open("POST",p,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var r,w=0;w<a.length;w++)n.apply(this,a[w]);function d(){r!==o.pathname&&(r=o.pathname,n("pageview"))}var c,f=window.history;f.pushState&&(c=f.pushState,f.pushState=function(){c.apply(this,arguments),d()},window.addEventListener("popstate",d)),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){r||"visible"!==s.visibilityState||d()}):d()}();