!function(){"use strict";var e,t,i,o=window.location,l=window.document,s=l.getElementById("plausible"),d=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event");function n(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(e){}var i={};i.n=e,i.u=o.href,i.d=s.getAttribute("data-domain"),i.r=l.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=t.props);var n=s.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),a=i.p||{};n.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);a[t]=a[t]||i}),i.p=a,i.h=1;var r=new XMLHttpRequest;r.open("POST",d,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&t&&t.callback&&t.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var r,w=0;w<a.length;w++)n.apply(this,a[w]);function p(){r=o.pathname,n("pageview")}window.addEventListener("hashchange",p),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){r||"visible"!==l.visibilityState||p()}):p()}();