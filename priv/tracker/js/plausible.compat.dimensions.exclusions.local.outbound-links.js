!function(){"use strict";var e,t,i,s=window.location,l=window.document,p=l.getElementById("plausible"),u=p.getAttribute("data-api")||(e=p.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),c=p&&p.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(c)for(var i=0;i<c.length;i++)if("pageview"===e&&s.pathname.match(new RegExp("^"+c[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=e,a.u=s.href,a.d=p.getAttribute("data-domain"),a.r=l.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var n=p.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),r=a.p&&JSON.parse(a.p)||{};n.forEach(function(e){var t=e.replace("event-",""),i=p.getAttribute(e);r[t]=r[t]||i}),a.p=JSON.stringify(r);var o=new XMLHttpRequest;o.open("POST",u,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function n(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==s.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){s.href=t.href},150),e.preventDefault()))}l.addEventListener("click",n),l.addEventListener("auxclick",n);var r=window.plausible&&window.plausible.q||[];window.plausible=a;for(var o,f=0;f<r.length;f++)a.apply(this,r[f]);function w(){o!==s.pathname&&(o=s.pathname,a("pageview"))}var g,h=window.history;h.pushState&&(g=h.pushState,h.pushState=function(){g.apply(this,arguments),w()},window.addEventListener("popstate",w)),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){o||"visible"!==l.visibilityState||w()}):w()}();