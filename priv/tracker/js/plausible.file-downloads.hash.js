!function(){"use strict";var o=window.location,n=window.document,r=n.currentScript,l=r.getAttribute("data-api")||new URL(r.src).origin+"/api/event";function p(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return p("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return p("localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=r.getAttribute("data-domain"),i.r=n.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props),i.h=1;var a=new XMLHttpRequest;a.open("POST",l,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4===a.readyState&&e&&e.callback&&e.callback()}}}var e=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],i=r.getAttribute("file-types"),a=r.getAttribute("add-file-types"),s=i&&i.split(",")||a&&a.split(",").concat(e)||e;function c(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var n,r=e&&e.href&&e.href.split("?")[0];r&&(n=r.split(".").pop(),s.some(function(t){return t===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}n.addEventListener("click",c),n.addEventListener("auxclick",c);var d=window.plausible&&window.plausible.q||[];window.plausible=t;for(var w,u=0;u<d.length;u++)t.apply(this,d[u]);function f(){w=o.pathname,t("pageview")}window.addEventListener("hashchange",f),"prerender"===n.visibilityState?n.addEventListener("visibilitychange",function(){w||"visible"!==n.visibilityState||f()}):f()}();