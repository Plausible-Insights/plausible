!function(){"use strict";var e,t,a,i=window.location,r=window.document,n=window.localStorage,o=r.getElementById("plausible"),l=o.getAttribute("data-api")||(e=o.src.split("/"),t=e[0],a=e[2],t+"//"+a+"/api/event"),s=n&&n.plausible_ignore;function c(e){console.warn("Ignoring Event: "+e)}function p(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(i.hostname)||"file:"===i.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==s)return c("localStorage flag");var a={};a.n=e,a.u=typeof t.u==typeof p?t.u():t.u||i.href,a.d=o.getAttribute("data-domain"),a.r=r.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var n=new XMLHttpRequest;n.open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(a)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}}}function u(e){for(var t=e.target,a="auxclick"==e.type&&2==e.which,n="click"==e.type;t&&(void 0===t.tagName||"a"!=t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==i.host&&((a||n)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!n||(setTimeout(function(){i.href=t.href},150),e.preventDefault()))}r.addEventListener("click",u),r.addEventListener("auxclick",u);var d=window.plausible&&window.plausible.q||[];window.plausible=p;for(var f=0;f<d.length;f++)p.apply(this,d[f])}();