!function(){"use strict";var e,t,a=window.location,r=window.document,i=window.localStorage,o=r.getElementById("plausible"),l=o.getAttribute("data-api")||(e=(t=(e=o).src.split("/"))[0],t=t[2],e+"//"+t+"/api/event"),s=i&&i.plausible_ignore;function n(e,t){var i,n;window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress||("true"!=s?((i={}).n=e,i.u=a.href,i.d=o.getAttribute("data-domain"),i.r=r.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props)),i.h=1,(n=new XMLHttpRequest).open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}):console.warn("Ignoring Event: localStorage flag"))}function d(e){for(var t=e.target,i="auxclick"==e.type&&2==e.which,n="click"==e.type;t&&(void 0===t.tagName||"a"!=t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==a.host&&((i||n)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!n||(setTimeout(function(){a.href=t.href},150),e.preventDefault()))}r.addEventListener("click",d),r.addEventListener("auxclick",d);var c=window.plausible&&window.plausible.q||[];window.plausible=n;for(var p,w=0;w<c.length;w++)n.apply(this,c[w]);function u(){p=a.pathname,n("pageview")}window.addEventListener("hashchange",u),"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){p||"visible"!==r.visibilityState||u()}):u()}();