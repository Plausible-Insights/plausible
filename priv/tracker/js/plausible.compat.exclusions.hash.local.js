!function(){"use strict";var e,t,i,r=window.location,o=window.document,l=o.getElementById("plausible"),w=l.getAttribute("data-api")||(e=l.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),d=l&&l.getAttribute("data-exclude").split(",");function s(e){console.warn("Ignoring Event: "+e)}function n(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return s("localStorage flag")}catch(e){}if(d)for(var i=0;i<d.length;i++)if("pageview"===e&&r.pathname.match(new RegExp("^"+d[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return s("exclusion rule");var n={};n.n=e,n.u=r.href,n.d=l.getAttribute("data-domain"),n.r=o.referrer||null,n.w=window.screen.width||window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=t.props),n.h=1;var a=new XMLHttpRequest;a.open("POST",w,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(n)),a.onreadystatechange=function(){4===a.readyState&&t&&t.callback&&t.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var p,c=0;c<a.length;c++)n.apply(this,a[c]);function u(){p=r.pathname,n("pageview")}window.addEventListener("hashchange",u),"prerender"===o.visibilityState?o.addEventListener("visibilitychange",function(){p||"visible"!==o.visibilityState||u()}):u()}();