!function(){"use strict";var e,t,n,o=window.location,l=window.document,s=l.getElementById("plausible"),c=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],n=e[2],t+"//"+n+"/api/event");function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(e){}var n={};n.n=e,n.u=t&&t.u?t.u:o.href,n.d=s.getAttribute("data-domain"),n.r=l.referrer||null,n.w=window.screen.width||window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=t.props);var a=s.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),r=n.p||{};a.forEach(function(e){var t=e.replace("event-",""),n=s.getAttribute(e);r[t]=r[t]||n}),n.p=r,n.h=1;var i=new XMLHttpRequest;i.open("POST",c,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(n)),i.onreadystatechange=function(){4===i.readyState&&t&&t.callback&&t.callback()}}}function r(e){for(var t=e.target,n="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==o.host&&((n||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}l.addEventListener("click",r),l.addEventListener("auxclick",r);var i=window.plausible&&window.plausible.q||[];window.plausible=a;for(var u=0;u<i.length;u++)a.apply(this,i[u])}();