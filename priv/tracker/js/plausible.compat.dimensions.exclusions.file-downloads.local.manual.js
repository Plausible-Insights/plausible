!function(){"use strict";var e,t,a,u=window.location,d=window.document,f=d.getElementById("plausible"),g=f.getAttribute("data-api")||(e=f.src.split("/"),t=e[0],a=e[2],t+"//"+a+"/api/event");function v(e){console.warn("Ignoring Event: "+e)}function r(e,t){try{if("true"===window.localStorage.plausible_ignore)return v("localStorage flag")}catch(e){}var a=f&&f.getAttribute("data-include"),r=f&&f.getAttribute("data-exclude");if("pageview"===e){var i=!a||a&&a.split(",").some(l),n=r&&r.split(",").some(l);if(!i||n)return v("exclusion rule")}function l(e){var t=u.pathname;return console.log(t),t.match(new RegExp("^"+e.trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$"))}var p={};p.n=e,p.u=t&&t.u?t.u:u.href,p.d=f.getAttribute("data-domain"),p.r=d.referrer||null,p.w=window.innerWidth,t&&t.meta&&(p.m=JSON.stringify(t.meta)),t&&t.props&&(p.p=t.props);var o=f.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),c=p.p||{};o.forEach(function(e){var t=e.replace("event-",""),a=f.getAttribute(e);c[t]=c[t]||a}),p.p=c;var s=new XMLHttpRequest;s.open("POST",g,!0),s.setRequestHeader("Content-Type","text/plain"),s.send(JSON.stringify(p)),s.onreadystatechange=function(){4===s.readyState&&t&&t.callback&&t.callback()}}var i=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],n=f.getAttribute("file-types"),l=f.getAttribute("add-file-types"),p=n&&n.split(",")||l&&l.split(",").concat(i)||i;function o(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var i,n=t&&t.href&&t.href.split("?")[0];n&&(i=n.split(".").pop(),p.some(function(e){return e===i}))&&((a||r)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){u.href=t.href},150),e.preventDefault()))}d.addEventListener("click",o),d.addEventListener("auxclick",o);var c=window.plausible&&window.plausible.q||[];window.plausible=r;for(var s=0;s<c.length;s++)r.apply(this,c[s])}();