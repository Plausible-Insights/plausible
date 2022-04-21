!function(){"use strict";var t,e,i,o=window.location,p=window.document,s=p.getElementById("plausible"),l=s.getAttribute("data-api")||(t=s.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function c(t){console.warn("Ignoring Event: "+t)}function a(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=s.getAttribute("data-domain"),i.r=p.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var a=s.getAttributeNames().filter(function(t){return"event"===t.substring(0,5)}),r=i.p&&JSON.parse(i.p)||{};a.forEach(function(t){var e=t.replace("event-",""),i=s.getAttribute(t);r[e]=i}),i.p=r;var n=new XMLHttpRequest;n.open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4===n.readyState&&e&&e.callback&&e.callback()}}}function r(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}p.addEventListener("click",r),p.addEventListener("auxclick",r);var n=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],u=s.getAttribute("file-types"),d=s.getAttribute("add-file-types"),f=u&&u.split(",")||d&&d.split(",").concat(n)||n;function h(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var r,n=e&&e.href&&e.href.split("?")[0];n&&(r=n.split(".").pop(),f.some(function(t){return t===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}p.addEventListener("click",h),p.addEventListener("auxclick",h);var w=window.plausible&&window.plausible.q||[];window.plausible=a;for(var v,g=0;g<w.length;g++)a.apply(this,w[g]);function m(){v!==o.pathname&&(v=o.pathname,a("pageview"))}var y,b=window.history;b.pushState&&(y=b.pushState,b.pushState=function(){y.apply(this,arguments),m()},window.addEventListener("popstate",m)),"prerender"===p.visibilityState?p.addEventListener("visibilitychange",function(){v||"visible"!==p.visibilityState||m()}):m()}();