!function(){"use strict";var i=window.location,o=window.document,e=window.localStorage,l=o.currentScript,c=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event",s=e&&e.plausible_ignore,p=l&&l.getAttribute("data-exclude").split(",");function u(e){console.warn("Ignoring Event: "+e)}function d(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(i.hostname)||"file:"===i.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==s)return u("localStorage flag");if(p)for(var a=0;a<p.length;a++)if("pageview"==e&&i.pathname.match(new RegExp("^"+p[a].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return u("exclusion rule");var r={};r.n=e,r.u=typeof t.u==typeof d?t.u():t.u||i.href,r.d=l.getAttribute("data-domain"),r.r=o.referrer||null,r.w=window.innerWidth,t&&t.meta&&(r.m=JSON.stringify(t.meta)),t&&t.props&&(r.p=JSON.stringify(t.props)),r.h=1;var n=new XMLHttpRequest;n.open("POST",c,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(r)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}}}function t(e){for(var t=e.target,a="auxclick"==e.type&&2==e.which,r="click"==e.type;t&&(void 0===t.tagName||"a"!=t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==i.host&&((a||r)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){i.href=t.href},150),e.preventDefault()))}o.addEventListener("click",t),o.addEventListener("auxclick",t);var a=window.plausible&&window.plausible.q||[];window.plausible=d;for(var r=0;r<a.length;r++)d.apply(this,a[r])}();