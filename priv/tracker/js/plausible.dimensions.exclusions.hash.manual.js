!function(){"use strict";var l=window.location,s=window.document,u=s.currentScript,c=u.getAttribute("data-api")||new URL(u.src).origin+"/api/event",p=u&&u.getAttribute("data-exclude").split(",");function w(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(l.hostname)||"file:"===l.protocol)return w("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return w("localStorage flag")}catch(e){}if(p)for(var n=0;n<p.length;n++)if("pageview"===e&&l.pathname.match(new RegExp("^"+p[n].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return w("exclusion rule");var r={};r.n=e,r.u=t&&t.u?t.u:l.href,r.d=u.getAttribute("data-domain"),r.r=s.referrer||null,r.w=window.innerWidth,t&&t.meta&&(r.m=JSON.stringify(t.meta)),t&&t.props&&(r.p=JSON.stringify(t.props));var i=u.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),a=r.p&&JSON.parse(r.p)||{};i.forEach(function(e){var t=e.replace("event-",""),n=u.getAttribute(e);a[t]=a[t]||n}),r.p=JSON.stringify(a),r.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(r)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var t=window.plausible&&window.plausible.q||[];window.plausible=e;for(var n=0;n<t.length;n++)e.apply(this,t[n])}();