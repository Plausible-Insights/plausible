!function(){"use strict";var a=window.location,r=window.document,e=window.localStorage,o=r.currentScript,w=o.getAttribute("data-api")||new URL(o.src).origin+"/api/event",l=e&&e.plausible_ignore;function d(e,t){var n,i;window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress||("true"!=l?((n={}).n=e,n.u=typeof t?.u==typeof d?t.u():t?.u||a.href,n.d=o.getAttribute("data-domain"),n.r=r.referrer||null,n.w=window.innerWidth,t&&t.meta&&(n.m=JSON.stringify(t.meta)),t&&t.props&&(n.p=JSON.stringify(t.props)),(i=new XMLHttpRequest).open("POST",w,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(n)),i.onreadystatechange=function(){4==i.readyState&&t&&t.callback&&t.callback()}):console.warn("Ignoring Event: localStorage flag"))}var t=window.plausible&&window.plausible.q||[];window.plausible=d;for(var n=0;n<t.length;n++)d.apply(this,t[n])}();