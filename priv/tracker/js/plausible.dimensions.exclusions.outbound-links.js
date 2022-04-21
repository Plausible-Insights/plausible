!function(){"use strict";var l=window.location,s=window.document,p=s.currentScript,c=p.getAttribute("data-api")||new URL(p.src).origin+"/api/event",u=p&&p.getAttribute("data-exclude").split(",");function d(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(l.hostname)||"file:"===l.protocol)return d("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(t){}if(u)for(var i=0;i<u.length;i++)if("pageview"===t&&l.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=t,a.u=l.href,a.d=p.getAttribute("data-domain"),a.r=s.referrer||null,a.w=window.innerWidth,e&&e.meta&&(a.m=JSON.stringify(e.meta)),e&&e.props&&(a.p=JSON.stringify(e.props));var n=p.getAttributeNames().filter(function(t){return"event"===t.substring(0,5)}),r=a.p&&JSON.parse(a.p)||{};n.forEach(function(t){var e=t.replace("event-",""),i=p.getAttribute(t);r[e]=i}),a.p=r;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==l.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){l.href=e.href},150),t.preventDefault()))}s.addEventListener("click",e),s.addEventListener("auxclick",e);var i=window.plausible&&window.plausible.q||[];window.plausible=t;for(var a,n=0;n<i.length;n++)t.apply(this,i[n]);function r(){a!==l.pathname&&(a=l.pathname,t("pageview"))}var o,f=window.history;f.pushState&&(o=f.pushState,f.pushState=function(){o.apply(this,arguments),r()},window.addEventListener("popstate",r)),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){a||"visible"!==s.visibilityState||r()}):r()}();