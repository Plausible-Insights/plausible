!function(){"use strict";var a=window.location,o=window.document,e=window.localStorage,l=o.currentScript,p=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event",w=e&&e.plausible_ignore,s=l&&l.getAttribute("data-exclude").split(",");function u(e){console.warn("Ignoring Event: "+e)}function c(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(a.hostname)||"file:"===a.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==w)return u("localStorage flag");if(s)for(var n=0;n<s.length;n++)if("pageview"==e&&a.pathname.match(new RegExp("^"+s[n].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return u("exclusion rule");var i={};i.n=e,i.u=typeof t.u==typeof c?t.u():t.u||a.href,i.d=l.getAttribute("data-domain"),i.r=o.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props)),i.h=1;var r=new XMLHttpRequest;r.open("POST",p,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4==r.readyState&&t&&t.callback&&t.callback()}}}var t=window.plausible&&window.plausible.q||[];window.plausible=c;for(var n=0;n<t.length;n++)c.apply(this,t[n])}();