!function(){"use strict";var e,t,i,l=window.location,s=window.document,p=s.getElementById("plausible"),c=p.getAttribute("data-api")||(e=p.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),u=p&&p.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(u)for(var i=0;i<u.length;i++)if("pageview"===e&&l.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=e,a.u=l.href,a.d=p.getAttribute("data-domain"),a.r=s.referrer||null,a.w=window.screen.width||window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=t.props);var n=p.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),r=a.p||{};n.forEach(function(e){var t=e.replace("event-",""),i=p.getAttribute(e);r[t]=r[t]||i}),a.p=r;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function n(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==l.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}s.addEventListener("click",n),s.addEventListener("auxclick",n);var r=window.plausible&&window.plausible.q||[];window.plausible=a;for(var o,w=0;w<r.length;w++)a.apply(this,r[w]);function f(){o!==l.pathname&&(o=l.pathname,a("pageview"))}var h,g=window.history;g.pushState&&(h=g.pushState,g.pushState=function(){h.apply(this,arguments),f()},window.addEventListener("popstate",f)),"prerender"===s.visibilityState?s.addEventListener("visibilitychange",function(){o||"visible"!==s.visibilityState||f()}):f()}();