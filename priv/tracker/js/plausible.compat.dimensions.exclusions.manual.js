!function(){"use strict";var e,t,n,l=window.location,s=window.document,p=s.getElementById("plausible"),u=p.getAttribute("data-api")||(e=p.src.split("/"),t=e[0],n=e[2],t+"//"+n+"/api/event"),c=p&&p.getAttribute("data-exclude").split(",");function w(e){console.warn("Ignoring Event: "+e)}function r(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(l.hostname)||"file:"===l.protocol)return w("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return w("localStorage flag")}catch(e){}if(c)for(var n=0;n<c.length;n++)if("pageview"===e&&l.pathname.match(new RegExp("^"+c[n].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return w("exclusion rule");var r={};r.n=e,r.u=t&&t.u?t.u:l.href,r.d=p.getAttribute("data-domain"),r.r=s.referrer||null,r.w=window.innerWidth,t&&t.meta&&(r.m=JSON.stringify(t.meta)),t&&t.props&&(r.p=JSON.stringify(t.props));var a=p.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),i=r.p&&JSON.parse(r.p)||{};a.forEach(function(e){var t=e.replace("event-",""),n=p.getAttribute(e);i[t]=n}),r.p=i;var o=new XMLHttpRequest;o.open("POST",u,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(r)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=r;for(var i=0;i<a.length;i++)r.apply(this,a[i])}();