!function(){"use strict";var t,e,a,o=window.location,r=window.document,n=r.getElementById("plausible"),l=n.getAttribute("data-api")||(t=n.src.split("/"),e=t[0],a=t[2],e+"//"+a+"/api/event");function p(t){console.warn("Ignoring Event: "+t)}function i(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return p("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return p("localStorage flag")}catch(t){}var a={};a.n=t,a.u=e&&e.u?e.u:o.href,a.d=n.getAttribute("data-domain"),a.r=r.referrer||null,a.w=window.screen.width||window.innerWidth,e&&e.meta&&(a.m=JSON.stringify(e.meta)),e&&e.props&&(a.p=e.props),a.h=1;var i=new XMLHttpRequest;i.open("POST",l,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(a)),i.onreadystatechange=function(){4===i.readyState&&e&&e.callback&&e.callback()}}}var s=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],c=n.getAttribute("file-types"),d=n.getAttribute("add-file-types"),w=c&&c.split(",")||d&&d.split(",").concat(s)||s;function u(t){for(var e=t.target,a="auxclick"===t.type&&2===t.which,i="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var r,n=e&&e.href&&e.href.split("?")[0];n&&(r=n.split(".").pop(),w.some(function(t){return t===r}))&&((a||i)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!i||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}r.addEventListener("click",u),r.addEventListener("auxclick",u);var f=window.plausible&&window.plausible.q||[];window.plausible=i;for(var g=0;g<f.length;g++)i.apply(this,f[g])}();