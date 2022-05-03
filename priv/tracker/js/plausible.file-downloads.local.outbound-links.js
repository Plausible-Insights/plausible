!function(){"use strict";var o=window.location,r=window.document,n=r.currentScript,p=n.getAttribute("data-api")||new URL(n.src).origin+"/api/event";function t(t,e){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=n.getAttribute("data-domain"),i.r=r.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var a=new XMLHttpRequest;a.open("POST",p,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4===a.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==o.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}r.addEventListener("click",e),r.addEventListener("auxclick",e);var i=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],a=n.getAttribute("file-types"),s=n.getAttribute("add-file-types"),l=a&&a.split(",")||s&&s.split(",").concat(i)||i;function c(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var r,n=e&&e.href&&e.href.split("?")[0];n&&(r=n.split(".").pop(),l.some(function(t){return t===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}r.addEventListener("click",c),r.addEventListener("auxclick",c);var d=window.plausible&&window.plausible.q||[];window.plausible=t;for(var u,w=0;w<d.length;w++)t.apply(this,d[w]);function f(){u!==o.pathname&&(u=o.pathname,t("pageview"))}var h,v=window.history;v.pushState&&(h=v.pushState,v.pushState=function(){h.apply(this,arguments),f()},window.addEventListener("popstate",f)),"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){u||"visible"!==r.visibilityState||f()}):f()}();