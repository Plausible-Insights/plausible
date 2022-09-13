!function(){"use strict";var c=window.location,o=window.document,l=o.currentScript,s=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event";function u(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(c.hostname)||"file:"===c.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return u("localStorage flag")}catch(t){}var i={};i.n=t,i.u=c.href,i.d=l.getAttribute("data-domain"),i.r=o.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var n=l.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=i.p||{};n.forEach(function(t){var e=t.replace("event-",""),i=l.getAttribute(t);a[e]=a[e]||i}),i.p=a;var r=new XMLHttpRequest;r.open("POST",s,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var e=window.plausible&&window.plausible.q||[];window.plausible=t;for(var i,n=0;n<e.length;n++)t.apply(this,e[n]);function a(){i!==c.pathname&&(i=c.pathname,t("pageview"))}var r,p=window.history;function d(t){if("auxclick"!==t.type||1===t.button){var e,i,n,a,r,o,l=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target);l&&l.href&&l.href.split("?")[0];if((o=l)&&o.href&&o.host&&o.host!==c.host){var s={url:l.href};return a=s,r=!(n="Outbound Link: Click"),void(!function(t,e){if(!t.defaultPrevented){var i=!e.target||e.target.match(/^_(self|parent|top)$/i),n=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return i&&n}}(e=t,i=l)?plausible(n,{props:a}):(plausible(n,{props:a,callback:u}),setTimeout(u,5e3),e.preventDefault()))}}function u(){r||(r=!0,window.location=i.href)}}p.pushState&&(r=p.pushState,p.pushState=function(){r.apply(this,arguments),a()},window.addEventListener("popstate",a)),"prerender"===o.visibilityState?o.addEventListener("visibilitychange",function(){i||"visible"!==o.visibilityState||a()}):a(),o.addEventListener("click",d),o.addEventListener("auxclick",d)}();