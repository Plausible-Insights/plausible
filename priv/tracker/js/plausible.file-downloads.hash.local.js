!function(){"use strict";var a=window.location,r=window.document,o=r.currentScript,l=o.getAttribute("data-api")||new URL(o.src).origin+"/api/event";function t(t,e){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=a.href,i.d=o.getAttribute("data-domain"),i.r=r.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props),i.h=1;var n=new XMLHttpRequest;n.open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(i)),n.onreadystatechange=function(){4===n.readyState&&e&&e.callback&&e.callback()}}var e=window.plausible&&window.plausible.q||[];window.plausible=t;for(var i,n=0;n<e.length;n++)t.apply(this,e[n]);function p(){i=a.pathname,t("pageview")}function c(t){if("auxclick"!==t.type||1===t.button){var e,i,n,a,r,o=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target),l=o&&o.href&&o.href.split("?")[0];if(function(t){if(!t)return!1;var e=t.split(".").pop();return f.some(function(t){return t===e})}(l)){return a={url:l},r=!(n="File Download"),void(!function(t,e){if(!t.defaultPrevented){var i=!e.target||e.target.match(/^_(self|parent|top)$/i),n=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return i&&n}}(e=t,i=o)?plausible(n,{props:a}):(plausible(n,{props:a,callback:p}),setTimeout(p,5e3),e.preventDefault()))}}function p(){r||(r=!0,window.location=i.href)}}window.addEventListener("hashchange",p),"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){i||"visible"!==r.visibilityState||p()}):p(),r.addEventListener("click",c),r.addEventListener("auxclick",c);var s=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],u=o.getAttribute("file-types"),d=o.getAttribute("add-file-types"),f=u&&u.split(",")||d&&d.split(",").concat(s)||s}();