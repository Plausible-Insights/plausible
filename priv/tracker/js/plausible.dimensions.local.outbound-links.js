!function(){"use strict";var o=window.location,s=window.document,p=s.currentScript,c=p.getAttribute("data-api")||new URL(p.src).origin+"/api/event";function t(t,e){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=p.getAttribute("data-domain"),i.r=s.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var n=p.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=i.p||{};n.forEach(function(t){var e=t.replace("event-",""),i=p.getAttribute(t);a[e]=a[e]||i}),i.p=a;var r=new XMLHttpRequest;r.open("POST",c,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,n="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((i||n)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!n||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}s.addEventListener("click",e),s.addEventListener("auxclick",e);var i=window.plausible&&window.plausible.q||[];window.plausible=t;for(var n,a=0;a<i.length;a++)t.apply(this,i[a]);function r(){n!==o.pathname&&(n=o.pathname,t("pageview"))}var l,u=window.history;u.pushState&&(l=u.pushState,u.pushState=function(){l.apply(this,arguments),r()},window.addEventListener("popstate",r)),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){n||"visible"!==s.visibilityState||r()}):r()}();