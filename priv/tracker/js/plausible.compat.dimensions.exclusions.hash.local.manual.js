!function(){"use strict";var e,t,n,l=window.location,u=window.document,w=u.getElementById("plausible"),p=w.getAttribute("data-api")||(e=w.src.split("/"),t=e[0],n=e[2],t+"//"+n+"/api/event"),s=w&&w.getAttribute("data-exclude").split(",");function c(e){console.warn("Ignoring Event: "+e)}function i(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(e){}if(s)for(var n=0;n<s.length;n++)if("pageview"===e&&l.pathname.match(new RegExp("^"+s[n].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return c("exclusion rule");var i={};i.n=e,i.u=t&&t.u?t.u:l.href,i.d=w.getAttribute("data-domain"),i.r=u.referrer||null,i.w=window.screen.width||window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=t.props);var r=w.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),a=i.p||{};r.forEach(function(e){var t=e.replace("event-",""),n=w.getAttribute(e);a[t]=a[t]||n}),i.p=a,i.h=1;var o=new XMLHttpRequest;o.open("POST",p,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(i)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var r=window.plausible&&window.plausible.q||[];window.plausible=i;for(var a=0;a<r.length;a++)i.apply(this,r[a])}();