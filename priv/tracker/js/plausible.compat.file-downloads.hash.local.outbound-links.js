!function(){"use strict";var t,e,i,a=window.location,r=window.document,o=r.getElementById("plausible"),l=o.getAttribute("data-api")||(t=o.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function n(t,e){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=a.href,i.d=o.getAttribute("data-domain"),i.r=r.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props),i.h=1;var n=new XMLHttpRequest;n.open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4===n.readyState&&e&&e.callback&&e.callback()}}var p=window.plausible&&window.plausible.q||[];window.plausible=n;for(var s,u=0;u<p.length;u++)n.apply(this,p[u]);function c(){s=a.pathname,n("pageview")}function d(t){if("auxclick"!==t.type||1===t.button){var e,i=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target),n=i&&i.href&&i.href.split("?")[0];if((e=i)&&e.href&&e.host&&e.host!==a.host)return f(t,i,"Outbound Link: Click",{url:i.href});if(function(t){if(!t)return!1;var e=t.split(".").pop();return h.some(function(t){return t===e})}(n))return f(t,i,"File Download",{url:n})}}function f(t,e,i,n){var a=!1;function r(){a||(a=!0,window.location=e.href)}!function(t,e){if(!t.defaultPrevented){var i=!e.target||e.target.match(/^_(self|parent|top)$/i),n=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return i&&n}}(t,e)?plausible(i,{props:n}):(plausible(i,{props:n,callback:r}),setTimeout(r,5e3),t.preventDefault())}window.addEventListener("hashchange",c),"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){s||"visible"!==r.visibilityState||c()}):c(),r.addEventListener("click",d),r.addEventListener("auxclick",d);var v=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],w=o.getAttribute("file-types"),g=o.getAttribute("add-file-types"),h=w&&w.split(",")||g&&g.split(",").concat(v)||v}();