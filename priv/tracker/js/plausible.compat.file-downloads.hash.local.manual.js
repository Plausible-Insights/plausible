!function(){"use strict";var t,e,a,r=window.location,n=window.document,o=n.getElementById("plausible"),l=o.getAttribute("data-api")||(t=o.src.split("/"),e=t[0],a=t[2],e+"//"+a+"/api/event");function i(t,e){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var a={};a.n=t,a.u=e&&e.u?e.u:r.href,a.d=o.getAttribute("data-domain"),a.r=n.referrer||null,a.w=window.innerWidth,e&&e.meta&&(a.m=JSON.stringify(e.meta)),e&&e.props&&(a.p=e.props),a.h=1;var i=new XMLHttpRequest;i.open("POST",l,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(a)),i.onreadystatechange=function(){4===i.readyState&&e&&e.callback&&e.callback()}}var p=window.plausible&&window.plausible.q||[];window.plausible=i;for(var u=0;u<p.length;u++)i.apply(this,p[u]);function c(t){if("auxclick"!==t.type||1===t.button){var e,a,i,r,n,o=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target),l=o&&o.href&&o.href.split("?")[0];if(function(t){if(!t)return!1;var e=t.split(".").pop();return w.some(function(t){return t===e})}(l)){return r={url:l},n=!(i="File Download"),void(!function(t,e){if(!t.defaultPrevented){var a=!e.target||e.target.match(/^_(self|parent|top)$/i),i=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return a&&i}}(e=t,a=o)?plausible(i,{props:r}):(plausible(i,{props:r,callback:p}),setTimeout(p,5e3),e.preventDefault()))}}function p(){n||(n=!0,window.location=a.href)}}n.addEventListener("click",c),n.addEventListener("auxclick",c);var s=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],d=o.getAttribute("file-types"),f=o.getAttribute("add-file-types"),w=d&&d.split(",")||f&&f.split(",").concat(s)||s}();