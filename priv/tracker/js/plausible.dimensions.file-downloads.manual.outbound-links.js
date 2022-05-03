!function(){"use strict";var o=window.location,l=window.document,p=l.currentScript,c=p.getAttribute("data-api")||new URL(p.src).origin+"/api/event";function s(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return s("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return s("localStorage flag")}catch(t){}var r={};r.n=t,r.u=e&&e.u?e.u:o.href,r.d=p.getAttribute("data-domain"),r.r=l.referrer||null,r.w=window.screen.width||window.innerWidth,e&&e.meta&&(r.m=JSON.stringify(e.meta)),e&&e.props&&(r.p=e.props);var a=p.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),i=r.p||{};a.forEach(function(t){var e=t.replace("event-",""),r=p.getAttribute(t);i[e]=i[e]||r}),r.p=i;var n=new XMLHttpRequest;n.open("POST",c,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(r)),n.onreadystatechange=function(){4===n.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,r="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((r||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}l.addEventListener("click",e),l.addEventListener("auxclick",e);var r=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],a=p.getAttribute("file-types"),i=p.getAttribute("add-file-types"),u=a&&a.split(",")||i&&i.split(",").concat(r)||r;function n(t){for(var e=t.target,r="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var i,n=e&&e.href&&e.href.split("?")[0];n&&(i=n.split(".").pop(),u.some(function(t){return t===i}))&&((r||a)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}l.addEventListener("click",n),l.addEventListener("auxclick",n);var f=window.plausible&&window.plausible.q||[];window.plausible=t;for(var d=0;d<f.length;d++)t.apply(this,f[d])}();