!function(){"use strict";var s=window.location,c=window.document,u=c.currentScript,d=u.getAttribute("data-api")||new URL(u.src).origin+"/api/event";function w(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(s.hostname)||"file:"===s.protocol)return w("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return w("localStorage flag")}catch(e){}var a=u&&u.getAttribute("data-include"),r=u&&u.getAttribute("data-exclude");if("pageview"===e){var i=!a||a&&a.split(",").some(p),n=r&&r.split(",").some(p);if(!i||n)return w("exclusion rule")}var o={};o.n=e,o.u=t&&t.u?t.u:s.href,o.d=u.getAttribute("data-domain"),o.r=c.referrer||null,o.w=window.innerWidth,t&&t.meta&&(o.m=JSON.stringify(t.meta)),t&&t.props&&(o.p=t.props),o.h=1;var l=new XMLHttpRequest;l.open("POST",d,!0),l.setRequestHeader("Content-Type","text/plain"),l.send(JSON.stringify(o)),l.onreadystatechange=function(){4===l.readyState&&t&&t.callback&&t.callback()}}function p(e){var t=s.pathname;return t+=s.hash,console.log(t),t.match(new RegExp("^"+e.trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$"))}}var t=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],a=u.getAttribute("file-types"),r=u.getAttribute("add-file-types"),o=a&&a.split(",")||r&&r.split(",").concat(t)||t;function i(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var i,n=t&&t.href&&t.href.split("?")[0];n&&(i=n.split(".").pop(),o.some(function(e){return e===i}))&&((a||r)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){s.href=t.href},150),e.preventDefault()))}c.addEventListener("click",i),c.addEventListener("auxclick",i);var n=window.plausible&&window.plausible.q||[];window.plausible=e;for(var l=0;l<n.length;l++)e.apply(this,n[l])}();