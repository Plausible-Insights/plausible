!function(){"use strict";var e,t,n,o=window.location,l=window.document,s=l.getElementById("plausible"),u=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],n=e[2],t+"//"+n+"/api/event");function r(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(e){}var n={};n.n=e,n.u=t&&t.u?t.u:o.href,n.d=s.getAttribute("data-domain"),n.r=l.referrer||null,n.w=window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=JSON.stringify(t.props));var r=s.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),a=n.p&&JSON.parse(n.p)||{};r.forEach(function(e){var t=e.replace("event-",""),n=s.getAttribute(e);a[t]=a[t]||n}),n.p=JSON.stringify(a);var i=new XMLHttpRequest;i.open("POST",u,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(n)),i.onreadystatechange=function(){4===i.readyState&&t&&t.callback&&t.callback()}}}function a(e){for(var t=e.target,n="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==o.host&&((n||r)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}l.addEventListener("click",a),l.addEventListener("auxclick",a);var i=window.plausible&&window.plausible.q||[];window.plausible=r;for(var c=0;c<i.length;c++)r.apply(this,i[c])}();