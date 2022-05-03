!function(){"use strict";var e,t,a,l=window.location,c=window.document,u=c.getElementById("plausible"),s=u.getAttribute("data-api")||(e=u.src.split("/"),t=e[0],a=e[2],t+"//"+a+"/api/event"),p=u&&u.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function n(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(p)for(var a=0;a<p.length;a++)if("pageview"===e&&l.pathname.match(new RegExp("^"+p[a].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var n={};n.n=e,n.u=t&&t.u?t.u:l.href,n.d=u.getAttribute("data-domain"),n.r=c.referrer||null,n.w=window.screen.width||window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=t.props);var r=u.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),i=n.p||{};r.forEach(function(e){var t=e.replace("event-",""),a=u.getAttribute(e);i[t]=i[t]||a}),n.p=i;var o=new XMLHttpRequest;o.open("POST",s,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(n)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function r(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,n="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==l.host&&((a||n)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!n||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}c.addEventListener("click",r),c.addEventListener("auxclick",r);var i=window.plausible&&window.plausible.q||[];window.plausible=n;for(var o=0;o<i.length;o++)n.apply(this,i[o])}();