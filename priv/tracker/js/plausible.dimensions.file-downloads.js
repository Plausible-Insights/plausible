!function(){"use strict";var o=window.location,p=window.document,s=p.currentScript,l=s.getAttribute("data-api")||new URL(s.src).origin+"/api/event";function c(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=s.getAttribute("data-domain"),i.r=p.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var a=s.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),n=i.p||{};a.forEach(function(t){var e=t.replace("event-",""),i=s.getAttribute(t);n[e]=n[e]||i}),i.p=n;var r=new XMLHttpRequest;r.open("POST",l,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var e=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],i=s.getAttribute("file-types"),a=s.getAttribute("add-file-types"),u=i&&i.split(",")||a&&a.split(",").concat(e)||e;function n(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var n,r=e&&e.href&&e.href.split("?")[0];r&&(n=r.split(".").pop(),u.some(function(t){return t===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}p.addEventListener("click",n),p.addEventListener("auxclick",n);var r=window.plausible&&window.plausible.q||[];window.plausible=t;for(var d,w=0;w<r.length;w++)t.apply(this,r[w]);function f(){d!==o.pathname&&(d=o.pathname,t("pageview"))}var v,g=window.history;g.pushState&&(v=g.pushState,g.pushState=function(){v.apply(this,arguments),f()},window.addEventListener("popstate",f)),"prerender"===p.visibilityState?p.addEventListener("visibilitychange",function(){d||"visible"!==p.visibilityState||f()}):f()}();