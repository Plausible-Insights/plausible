!function(){"use strict";var r=window.location,o=window.document,e=window.localStorage,l=o.currentScript,s=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event",w=e&&e.plausible_ignore,c=l&&l.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function t(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(r.hostname)||"file:"===r.protocol)return d("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==w)return d("localStorage flag");if(c)for(var i=0;i<c.length;i++)if("pageview"==e&&r.pathname.match(new RegExp("^"+c[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var n={};n.n=e,n.u=r.href,n.d=l.getAttribute("data-domain"),n.r=o.referrer||null,n.w=window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=JSON.stringify(t.props)),n.h=1;var a=new XMLHttpRequest;a.open("POST",s,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(n)),a.onreadystatechange=function(){4==a.readyState&&t&&t.callback&&t.callback()}}}var i=window.plausible&&window.plausible.q||[];window.plausible=t;for(var n,a=0;a<i.length;a++)t.apply(this,i[a]);function p(){n=r.pathname,t("pageview")}window.addEventListener("hashchange",p),"prerender"===o.visibilityState?o.addEventListener("visibilitychange",function(){n||"visible"!==o.visibilityState||p()}):p()}();