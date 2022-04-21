!function(){"use strict";var e,t,i,o=window.location,l=window.document,p=l.getElementById("plausible"),s=p.getAttribute("data-api")||(e=p.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event");function c(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(e){}var i={};i.n=e,i.u=o.href,i.d=p.getAttribute("data-domain"),i.r=l.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props));var a=p.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),r=i.p&&JSON.parse(i.p)||{};a.forEach(function(e){var t=e.replace("event-",""),i=p.getAttribute(e);r[t]=i}),i.p=r,i.h=1;var n=new XMLHttpRequest;n.open("POST",s,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4===n.readyState&&t&&t.callback&&t.callback()}}}function r(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==o.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}l.addEventListener("click",r),l.addEventListener("auxclick",r);var n=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],u=p.getAttribute("file-types"),d=p.getAttribute("add-file-types"),f=u&&u.split(",")||d&&d.split(",").concat(n)||n;function h(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var r,n=t&&t.href&&t.href.split("?")[0];n&&(r=n.split(".").pop(),f.some(function(e){return e===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}l.addEventListener("click",h),l.addEventListener("auxclick",h);var g=window.plausible&&window.plausible.q||[];window.plausible=a;for(var v,w=0;w<g.length;w++)a.apply(this,g[w]);function m(){v=o.pathname,a("pageview")}window.addEventListener("hashchange",m),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){v||"visible"!==l.visibilityState||m()}):m()}();