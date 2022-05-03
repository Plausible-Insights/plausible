!function(){"use strict";var e,t,a,o=window.location,r=window.document,n=r.getElementById("plausible"),l=n.getAttribute("data-api")||(e=n.src.split("/"),t=e[0],a=e[2],t+"//"+a+"/api/event");function p(e){console.warn("Ignoring Event: "+e)}function i(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return p("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return p("localStorage flag")}catch(e){}var a={};a.n=e,a.u=t&&t.u?t.u:o.href,a.d=n.getAttribute("data-domain"),a.r=r.referrer||null,a.w=window.screen.width||window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=t.props);var i=new XMLHttpRequest;i.open("POST",l,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(a)),i.onreadystatechange=function(){4===i.readyState&&t&&t.callback&&t.callback()}}}function s(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,i="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==o.host&&((a||i)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!i||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}r.addEventListener("click",s),r.addEventListener("auxclick",s);var c=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],d=n.getAttribute("file-types"),u=n.getAttribute("add-file-types"),f=d&&d.split(",")||u&&u.split(",").concat(c)||c;function w(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,i="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var r,n=t&&t.href&&t.href.split("?")[0];n&&(r=n.split(".").pop(),f.some(function(e){return e===r}))&&((a||i)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!i||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}r.addEventListener("click",w),r.addEventListener("auxclick",w);var h=window.plausible&&window.plausible.q||[];window.plausible=i;for(var g=0;g<h.length;g++)i.apply(this,h[g])}();