!function(){"use strict";var t,e,i,o=window.location,s=window.document,p=s.getElementById("plausible"),l=p.getAttribute("data-api")||(t=p.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function n(t,e){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=p.getAttribute("data-domain"),i.r=s.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var n=p.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=i.p&&JSON.parse(i.p)||{};n.forEach(function(t){var e=t.replace("event-",""),i=p.getAttribute(t);a[e]=a[e]||i}),i.p=JSON.stringify(a);var r=new XMLHttpRequest;r.open("POST",l,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var r,d=0;d<a.length;d++)n.apply(this,a[d]);function w(){r!==o.pathname&&(r=o.pathname,n("pageview"))}var u,c=window.history;c.pushState&&(u=c.pushState,c.pushState=function(){u.apply(this,arguments),w()},window.addEventListener("popstate",w)),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){r||"visible"!==s.visibilityState||w()}):w()}();