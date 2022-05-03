!function(){"use strict";var t,e,i,o=window.location,p=window.document,l=p.getElementById("plausible"),s=l.getAttribute("data-api")||(t=l.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function c(t){console.warn("Ignoring Event: "+t)}function a(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=l.getAttribute("data-domain"),i.r=p.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var a=l.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),n=i.p||{};a.forEach(function(t){var e=t.replace("event-",""),i=l.getAttribute(t);n[e]=n[e]||i}),i.p=n;var r=new XMLHttpRequest;r.open("POST",s,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}function n(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}p.addEventListener("click",n),p.addEventListener("auxclick",n);var r=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],u=l.getAttribute("file-types"),d=l.getAttribute("add-file-types"),f=u&&u.split(",")||d&&d.split(",").concat(r)||r;function h(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var n,r=e&&e.href&&e.href.split("?")[0];r&&(n=r.split(".").pop(),f.some(function(t){return t===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}p.addEventListener("click",h),p.addEventListener("auxclick",h);var w=window.plausible&&window.plausible.q||[];window.plausible=a;for(var v,g=0;g<w.length;g++)a.apply(this,w[g]);function m(){v!==o.pathname&&(v=o.pathname,a("pageview"))}var y,b=window.history;b.pushState&&(y=b.pushState,b.pushState=function(){y.apply(this,arguments),m()},window.addEventListener("popstate",m)),"prerender"===p.visibilityState?p.addEventListener("visibilitychange",function(){v||"visible"!==p.visibilityState||m()}):m()}();