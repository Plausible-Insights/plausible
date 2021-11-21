!function(){"use strict";var t,e,n=window.location,r=window.document,i=window.localStorage,o=r.getElementById("plausible"),l=o.getAttribute("data-api")||(t=(e=(t=o).src.split("/"))[0],e=e[2],t+"//"+e+"/api/event"),s=i&&i.plausible_ignore;function p(t){console.warn("Ignoring Event: "+t)}function a(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(n.hostname)||"file:"===n.protocol)return p("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){if("true"==s)return p("localStorage flag");var i={};i.n=t,i.u=n.href,i.d=o.getAttribute("data-domain"),i.r=r.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var a=new XMLHttpRequest;a.open("POST",l,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4==a.readyState&&e&&e.callback&&e.callback()}}}function c(t){for(var e=t.target,i="auxclick"==t.type&&2==t.which,a="click"==t.type;e&&(void 0===e.tagName||"a"!=e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==n.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){n.href=e.href},150),t.preventDefault()))}r.addEventListener("click",c),r.addEventListener("auxclick",c);var d=window.plausible&&window.plausible.q||[];window.plausible=a;for(var u,w=0;w<d.length;w++)a.apply(this,d[w]);function h(){u!==n.pathname&&(u=n.pathname,a("pageview"))}var f,i=window.history;i.pushState&&(f=i.pushState,i.pushState=function(){f.apply(this,arguments),h()},window.addEventListener("popstate",h)),"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){u||"visible"!==r.visibilityState||h()}):h()}();