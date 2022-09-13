!function(){"use strict";var t,e,i,o=window.location,l=window.document,p=l.getElementById("plausible"),s=p.getAttribute("data-api")||(t=p.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function u(t){console.warn("Ignoring Event: "+t)}function n(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return u("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=p.getAttribute("data-domain"),i.r=l.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var n=p.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),r=i.p||{};n.forEach(function(t){var e=t.replace("event-",""),i=p.getAttribute(t);r[e]=r[e]||i}),i.p=r,i.h=1;var a=new XMLHttpRequest;a.open("POST",s,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4===a.readyState&&e&&e.callback&&e.callback()}}}var r=window.plausible&&window.plausible.q||[];window.plausible=n;for(var a,c=0;c<r.length;c++)n.apply(this,r[c]);function f(){a=o.pathname,n("pageview")}function d(t){if("auxclick"!==t.type||1===t.button){var e,i=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target),n=i&&i.href&&i.href.split("?")[0];if((e=i)&&e.href&&e.host&&e.host!==o.host)return w(t,i,"Outbound Link: Click",{url:i.href});if(function(t){if(!t)return!1;var e=t.split(".").pop();return b.some(function(t){return t===e})}(n))return w(t,i,"File Download",{url:n})}}function w(t,e,i,n){var r=!1;function a(){r||(r=!0,window.location=e.href)}!function(t,e){if(!t.defaultPrevented){var i=!e.target||e.target.match(/^_(self|parent|top)$/i),n=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return i&&n}}(t,e)?plausible(i,{props:n}):(plausible(i,{props:n,callback:a}),setTimeout(a,5e3),t.preventDefault())}window.addEventListener("hashchange",f),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){a||"visible"!==l.visibilityState||f()}):f(),l.addEventListener("click",d),l.addEventListener("auxclick",d);var v=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],g=p.getAttribute("file-types"),h=p.getAttribute("add-file-types"),b=g&&g.split(",")||h&&h.split(",").concat(v)||v}();