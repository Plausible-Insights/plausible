!function(){"use strict";var t,e,i,p=window.location,o=window.document,l=o.getElementById("plausible"),s=l.getAttribute("data-api")||(t=l.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function u(t){console.warn("Ignoring Event: "+t)}function n(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(p.hostname)||"file:"===p.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return u("localStorage flag")}catch(t){}var i={};i.n=t,i.u=p.href,i.d=l.getAttribute("data-domain"),i.r=o.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var n=l.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=i.p||{};n.forEach(function(t){var e=t.replace("event-",""),i=l.getAttribute(t);a[e]=a[e]||i}),i.p=a;var r=new XMLHttpRequest;r.open("POST",s,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var a=window.plausible&&window.plausible.q||[];window.plausible=n;for(var r,c=0;c<a.length;c++)n.apply(this,a[c]);function d(){r!==p.pathname&&(r=p.pathname,n("pageview"))}var f,w=window.history;function h(t){if("auxclick"!==t.type||1===t.button){var e,i,n,a,r,o,l=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target);l&&l.href&&l.href.split("?")[0];if((o=l)&&o.href&&o.host&&o.host!==p.host){var s={url:l.href};return a=s,r=!(n="Outbound Link: Click"),void(!function(t,e){if(!t.defaultPrevented){var i=!e.target||e.target.match(/^_(self|parent|top)$/i),n=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return i&&n}}(e=t,i=l)?plausible(n,{props:a}):(plausible(n,{props:a,callback:u}),setTimeout(u,5e3),e.preventDefault()))}}function u(){r||(r=!0,window.location=i.href)}}w.pushState&&(f=w.pushState,w.pushState=function(){f.apply(this,arguments),d()},window.addEventListener("popstate",d)),"prerender"===o.visibilityState?o.addEventListener("visibilitychange",function(){r||"visible"!==o.visibilityState||d()}):d(),o.addEventListener("click",h),o.addEventListener("auxclick",h)}();