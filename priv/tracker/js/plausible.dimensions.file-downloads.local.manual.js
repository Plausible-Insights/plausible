!function(){"use strict";var o=window.location,p=window.document,l=p.currentScript,s=l.getAttribute("data-api")||new URL(l.src).origin+"/api/event";function t(t,e){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var r={};r.n=t,r.u=e&&e.u?e.u:o.href,r.d=l.getAttribute("data-domain"),r.r=p.referrer||null,r.w=window.innerWidth,e&&e.meta&&(r.m=JSON.stringify(e.meta)),e&&e.props&&(r.p=JSON.stringify(e.props));var i=l.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),a=r.p&&JSON.parse(r.p)||{};i.forEach(function(t){var e=t.replace("event-",""),r=l.getAttribute(t);a[e]=a[e]||r}),r.p=JSON.stringify(a);var n=new XMLHttpRequest;n.open("POST",s,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(r)),n.onreadystatechange=function(){4===n.readyState&&e&&e.callback&&e.callback()}}}var e=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],r=l.getAttribute("file-types"),i=l.getAttribute("add-file-types"),c=r&&r.split(",")||i&&i.split(",").concat(e)||e;function a(t){for(var e=t.target,r="auxclick"===t.type&&2===t.which,i="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var a,n=e&&e.href&&e.href.split("?")[0];n&&(a=n.split(".").pop(),c.some(function(t){return t===a}))&&((r||i)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!i||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}p.addEventListener("click",a),p.addEventListener("auxclick",a);var n=window.plausible&&window.plausible.q||[];window.plausible=t;for(var u=0;u<n.length;u++)t.apply(this,n[u])}();