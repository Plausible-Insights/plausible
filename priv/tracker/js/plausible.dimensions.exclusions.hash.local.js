!function(){"use strict";var l=window.location,s=window.document,p=s.currentScript,c=p.getAttribute("data-api")||new URL(p.src).origin+"/api/event",u=p&&p.getAttribute("data-exclude").split(",");function w(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return w("localStorage flag")}catch(e){}if(u)for(var i=0;i<u.length;i++)if("pageview"===e&&l.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return w("exclusion rule");var n={};n.n=e,n.u=l.href,n.d=p.getAttribute("data-domain"),n.r=s.referrer||null,n.w=window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=JSON.stringify(t.props));var r=p.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),a=n.p&&JSON.parse(n.p)||{};r.forEach(function(e){var t=e.replace("event-",""),i=p.getAttribute(e);a[t]=a[t]||i}),n.p=JSON.stringify(a),n.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(n)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var t=window.plausible&&window.plausible.q||[];window.plausible=e;for(var i,n=0;n<t.length;n++)e.apply(this,t[n]);function r(){i=l.pathname,e("pageview")}window.addEventListener("hashchange",r),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){i||"visible"!==s.visibilityState||r()}):r()}();