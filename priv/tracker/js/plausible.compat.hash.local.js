!function(){"use strict";var e,t,i,n,a=window.location,r=window.document,o=window.localStorage,l=r.getElementById("plausible"),w=l.getAttribute("data-api")||(e=l.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),d=o&&o.plausible_ignore;function s(e,t){var i,n;window.phantom||window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress||("true"!=d?((i={}).n=e,i.u=a.href,i.d=l.getAttribute("data-domain"),i.r=r.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props)),i.h=1,(n=new XMLHttpRequest).open("POST",w,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}):console.warn("Ignoring Event: localStorage flag"))}function p(){n=a.pathname,s("pageview")}window.addEventListener("hashchange",p);var c=window.plausible&&window.plausible.q||[];window.plausible=s;for(var g=0;g<c.length;g++)s.apply(this,c[g]);"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){n||"visible"!==r.visibilityState||p()}):p()}();