!function(){"use strict";var o=window.location,c=window.document,l=c.currentScript,u=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event";function e(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(e){}var n={};n.n=e,n.u=t&&t.u?t.u:o.href,n.d=l.getAttribute("data-domain"),n.r=c.referrer||null,n.w=window.screen.width||window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=t.props);var r=l.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),i=n.p||{};r.forEach(function(e){var t=e.replace("event-",""),n=l.getAttribute(e);i[t]=i[t]||n}),n.p=i;var a=new XMLHttpRequest;a.open("POST",u,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(n)),a.onreadystatechange=function(){4===a.readyState&&t&&t.callback&&t.callback()}}}function t(e){for(var t=e.target,n="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==o.host&&((n||r)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}c.addEventListener("click",t),c.addEventListener("auxclick",t);var n=window.plausible&&window.plausible.q||[];window.plausible=e;for(var r=0;r<n.length;r++)e.apply(this,n[r])}();