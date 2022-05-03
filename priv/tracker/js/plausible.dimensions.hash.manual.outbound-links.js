!function(){"use strict";var o=window.location,l=window.document,c=l.currentScript,s=c.getAttribute("data-api")||new URL(c.src).origin+"/api/event";function u(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return u("localStorage flag")}catch(t){}var n={};n.n=t,n.u=e&&e.u?e.u:o.href,n.d=c.getAttribute("data-domain"),n.r=l.referrer||null,n.w=window.screen.width||window.innerWidth,e&&e.meta&&(n.m=JSON.stringify(e.meta)),e&&e.props&&(n.p=e.props);var r=c.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=n.p||{};r.forEach(function(t){var e=t.replace("event-",""),n=c.getAttribute(t);a[e]=a[e]||n}),n.p=a,n.h=1;var i=new XMLHttpRequest;i.open("POST",s,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(n)),i.onreadystatechange=function(){4===i.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,n="auxclick"===t.type&&2===t.which,r="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((n||r)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!r||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}l.addEventListener("click",e),l.addEventListener("auxclick",e);var n=window.plausible&&window.plausible.q||[];window.plausible=t;for(var r=0;r<n.length;r++)t.apply(this,n[r])}();