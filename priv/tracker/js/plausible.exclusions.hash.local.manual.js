!function(){"use strict";var a=window.location,o=window.document,e=window.localStorage,l=o.currentScript,w=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event",p=e&&e.plausible_ignore,u=l&&l.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function s(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==p)return d("localStorage flag");if(u)for(var n=0;n<u.length;n++)if("pageview"==e&&a.pathname.match(new RegExp("^"+u[n].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var i={};i.n=e,i.u=typeof t?.u==typeof s?t.u():t?.u||a.href,i.d=l.getAttribute("data-domain"),i.r=o.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props)),i.h=1;var r=new XMLHttpRequest;r.open("POST",w,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4==r.readyState&&t&&t.callback&&t.callback()}}}var t=window.plausible&&window.plausible.q||[];window.plausible=s;for(var n=0;n<t.length;n++)s.apply(this,t[n])}();