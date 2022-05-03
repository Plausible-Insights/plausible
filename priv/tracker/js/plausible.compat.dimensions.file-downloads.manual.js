!function(){"use strict";var t,e,i,o=window.location,l=window.document,p=l.getElementById("plausible"),s=p.getAttribute("data-api")||(t=p.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function c(t){console.warn("Ignoring Event: "+t)}function a(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return c("localStorage flag")}catch(t){}var i={};i.n=t,i.u=e&&e.u?e.u:o.href,i.d=p.getAttribute("data-domain"),i.r=l.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var a=p.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),r=i.p||{};a.forEach(function(t){var e=t.replace("event-",""),i=p.getAttribute(t);r[e]=r[e]||i}),i.p=r;var n=new XMLHttpRequest;n.open("POST",s,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4===n.readyState&&e&&e.callback&&e.callback()}}}var r=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],n=p.getAttribute("file-types"),u=p.getAttribute("add-file-types"),d=n&&n.split(",")||u&&u.split(",").concat(r)||r;function w(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var r,n=e&&e.href&&e.href.split("?")[0];n&&(r=n.split(".").pop(),d.some(function(t){return t===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}l.addEventListener("click",w),l.addEventListener("auxclick",w);var f=window.plausible&&window.plausible.q||[];window.plausible=a;for(var g=0;g<f.length;g++)a.apply(this,f[g])}();