!function(){"use strict";var i=window.location,r=window.document,e=window.localStorage,o=r.currentScript,l=o.getAttribute("data-api")||new URL(o.src).origin+"/api/event",s=e&&e.plausible_ignore;function t(e,t){var n,a;window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress||("true"!=s?((n={}).n=e,n.u=t&&t.u?t.u:i.href,n.d=o.getAttribute("data-domain"),n.r=r.referrer||null,n.w=window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=JSON.stringify(t.props)),n.h=1,(a=new XMLHttpRequest).open("POST",l,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(n)),a.onreadystatechange=function(){4==a.readyState&&t&&t.callback&&t.callback()}):console.warn("Ignoring Event: localStorage flag"))}function n(e){for(var t=e.target,n="auxclick"==e.type&&2==e.which,a="click"==e.type;t&&(void 0===t.tagName||"a"!=t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==i.host&&((n||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){i.href=t.href},150),e.preventDefault()))}r.addEventListener("click",n),r.addEventListener("auxclick",n);var a=window.plausible&&window.plausible.q||[];window.plausible=t;for(var c=0;c<a.length;c++)t.apply(this,a[c])}();