!function(){"use strict";var e,t,r=window.location,o=window.document,n=window.localStorage,l=o.getElementById("plausible"),w=l.getAttribute("data-api")||(e=(t=(e=l).src.split("/"))[0],t=t[2],e+"//"+t+"/api/event"),p=n&&n.plausible_ignore,s=l&&l.getAttribute("data-exclude").split(",");function u(e){console.warn("Ignoring Event: "+e)}function i(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==p)return u("localStorage flag");if(s)for(var n=0;n<s.length;n++)if("pageview"==e&&r.pathname.match(new RegExp("^"+s[n].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return u("exclusion rule");var i={};i.n=e,i.u=t&&t.u?t.u:r.href,i.d=l.getAttribute("data-domain"),i.r=o.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props)),i.h=1;var a=new XMLHttpRequest;a.open("POST",w,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4==a.readyState&&t&&t.callback&&t.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=i;for(var d=0;d<a.length;d++)i.apply(this,a[d])}();