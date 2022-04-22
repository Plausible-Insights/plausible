!function(){"use strict";var e,t,r,l=window.location,s=window.document,u=s.getElementById("plausible"),c=u.getAttribute("data-api")||(e=u.src.split("/"),t=e[0],r=e[2],t+"//"+r+"/api/event"),p=u&&u.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(p)for(var r=0;r<p.length;r++)if("pageview"===e&&l.pathname.match(new RegExp("^"+p[r].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=e,a.u=t&&t.u?t.u:l.href,a.d=u.getAttribute("data-domain"),a.r=s.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var n=u.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),i=a.p&&JSON.parse(a.p)||{};n.forEach(function(e){var t=e.replace("event-",""),r=u.getAttribute(e);i[t]=i[t]||r}),a.p=JSON.stringify(i),a.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function n(e){for(var t=e.target,r="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==l.host&&((r||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}s.addEventListener("click",n),s.addEventListener("auxclick",n);var i=window.plausible&&window.plausible.q||[];window.plausible=a;for(var o=0;o<i.length;o++)a.apply(this,i[o])}();