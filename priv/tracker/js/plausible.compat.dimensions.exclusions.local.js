!function(){"use strict";var e,t,i,p=window.location,l=window.document,s=l.getElementById("plausible"),u=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),w=s&&s.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function n(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(w)for(var i=0;i<w.length;i++)if("pageview"===e&&p.pathname.match(new RegExp("^"+w[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var n={};n.n=e,n.u=p.href,n.d=s.getAttribute("data-domain"),n.r=l.referrer||null,n.w=window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=JSON.stringify(t.props));var a=s.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),r=n.p&&JSON.parse(n.p)||{};a.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);r[t]=i}),n.p=r;var o=new XMLHttpRequest;o.open("POST",u,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(n)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var r,o=0;o<a.length;o++)n.apply(this,a[o]);function c(){r!==p.pathname&&(r=p.pathname,n("pageview"))}var g,f=window.history;f.pushState&&(g=f.pushState,f.pushState=function(){g.apply(this,arguments),c()},window.addEventListener("popstate",c)),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){r||"visible"!==l.visibilityState||c()}):c()}();