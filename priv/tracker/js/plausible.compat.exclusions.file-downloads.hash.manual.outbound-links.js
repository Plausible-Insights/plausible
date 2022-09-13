!function(){"use strict";var t,e,r,u=window.location,s=window.document,c=s.getElementById("plausible"),f=c.getAttribute("data-api")||(t=c.src.split("/"),e=t[0],r=t[2],e+"//"+r+"/api/event");function d(t){console.warn("Ignoring Event: "+t)}function i(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(u.hostname)||"file:"===u.protocol)return d("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(t){}var r=c&&c.getAttribute("data-include"),i=c&&c.getAttribute("data-exclude");if("pageview"===t){var a=!r||r&&r.split(",").some(p),n=i&&i.split(",").some(p);if(!a||n)return d("exclusion rule")}var o={};o.n=t,o.u=e&&e.u?e.u:u.href,o.d=c.getAttribute("data-domain"),o.r=s.referrer||null,o.w=window.innerWidth,e&&e.meta&&(o.m=JSON.stringify(e.meta)),e&&e.props&&(o.p=e.props),o.h=1;var l=new XMLHttpRequest;l.open("POST",f,!0),l.setRequestHeader("Content-Type","text/plain"),l.send(JSON.stringify(o)),l.onreadystatechange=function(){4===l.readyState&&e&&e.callback&&e.callback()}}function p(t){var e=u.pathname;return(e+=u.hash).match(new RegExp("^"+t.trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$"))}}var a=window.plausible&&window.plausible.q||[];window.plausible=i;for(var n=0;n<a.length;n++)i.apply(this,a[n]);function o(t){if("auxclick"!==t.type||1===t.button){var e,r=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target),i=r&&r.href&&r.href.split("?")[0];if((e=r)&&e.href&&e.host&&e.host!==u.host)return l(t,r,"Outbound Link: Click",{url:r.href});if(function(t){if(!t)return!1;var e=t.split(".").pop();return v.some(function(t){return t===e})}(i))return l(t,r,"File Download",{url:i})}}function l(t,e,r,i){var a=!1;function n(){a||(a=!0,window.location=e.href)}!function(t,e){if(!t.defaultPrevented){var r=!e.target||e.target.match(/^_(self|parent|top)$/i),i=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return r&&i}}(t,e)?plausible(r,{props:i}):(plausible(r,{props:i,callback:n}),setTimeout(n,5e3),t.preventDefault())}s.addEventListener("click",o),s.addEventListener("auxclick",o);var p=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],w=c.getAttribute("file-types"),g=c.getAttribute("add-file-types"),v=w&&w.split(",")||g&&g.split(",").concat(p)||p}();