!function(){"use strict";var e,t,i=window.location,r=window.document,a=window.localStorage,o=r.getElementById("plausible"),l=o.getAttribute("data-api")||(e=(t=(e=o).src.split("/"))[0],t=t[2],e+"//"+t+"/api/event"),s=a&&a.plausible_ignore;function n(e,t){var a,n;window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress||("true"!=s?((a={}).n=e,a.u=t&&t.u?t.u:i.href,a.d=o.getAttribute("data-domain"),a.r=r.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props)),(n=new XMLHttpRequest).open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(a)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}):console.warn("Ignoring Event: localStorage flag"))}function d(e){for(var t=e.target,a="auxclick"==e.type&&2==e.which,n="click"==e.type;t&&(void 0===t.tagName||"a"!=t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==i.host&&((a||n)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!n||(setTimeout(function(){i.href=t.href},150),e.preventDefault()))}r.addEventListener("click",d),r.addEventListener("auxclick",d);var p=window.plausible&&window.plausible.q||[];window.plausible=n;for(var c=0;c<p.length;c++)n.apply(this,p[c])}();