!function(){"use strict";var r=window.location,o=window.document,e=window.localStorage,l=o.currentScript,s=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event",p=e&&e.plausible_ignore,c=l&&l.getAttribute("data-exclude").split(",");function u(e){console.warn("Ignoring Event: "+e)}function t(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(r.hostname)||"file:"===r.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==p)return u("localStorage flag");if(c)for(var i=0;i<c.length;i++)if("pageview"==e&&r.pathname.match(new RegExp("^"+c[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return u("exclusion rule");var a={};a.n=e,a.u=r.href,a.d=l.getAttribute("data-domain"),a.r=o.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var n=new XMLHttpRequest;n.open("POST",s,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(a)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}}}function i(e){for(var t=e.target,i="auxclick"==e.type&&2==e.which,a="click"==e.type;t&&(void 0===t.tagName||"a"!=t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==r.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){r.href=t.href},150),e.preventDefault()))}o.addEventListener("click",i),o.addEventListener("auxclick",i);var a=window.plausible&&window.plausible.q||[];window.plausible=t;for(var n,d=0;d<a.length;d++)t.apply(this,a[d]);function w(){n!==r.pathname&&(n=r.pathname,t("pageview"))}var h,e=window.history;e.pushState&&(h=e.pushState,e.pushState=function(){h.apply(this,arguments),w()},window.addEventListener("popstate",w)),"prerender"===o.visibilityState?o.addEventListener("visibilitychange",function(){n||"visible"!==o.visibilityState||w()}):w()}();