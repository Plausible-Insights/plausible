!function(){"use strict";var o=window.location,s=window.document,l=s.currentScript,c=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event";function p(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return p("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return p("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=l.getAttribute("data-domain"),i.r=s.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var n=l.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=i.p||{};n.forEach(function(t){var e=t.replace("event-",""),i=l.getAttribute(t);a[e]=a[e]||i}),i.p=a;var r=new XMLHttpRequest;r.open("POST",c,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,n="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((i||n)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!n||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}s.addEventListener("click",e),s.addEventListener("auxclick",e);var i=window.plausible&&window.plausible.q||[];window.plausible=t;for(var n,a=0;a<i.length;a++)t.apply(this,i[a]);function r(){n!==o.pathname&&(n=o.pathname,t("pageview"))}var u,d=window.history;d.pushState&&(u=d.pushState,d.pushState=function(){u.apply(this,arguments),r()},window.addEventListener("popstate",r)),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){n||"visible"!==s.visibilityState||r()}):r()}();