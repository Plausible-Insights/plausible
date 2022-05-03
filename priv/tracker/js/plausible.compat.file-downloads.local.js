!function(){"use strict";var t,e,i,o=window.location,n=window.document,r=n.getElementById("plausible"),p=r.getAttribute("data-api")||(t=r.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function a(t,e){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=o.href,i.d=r.getAttribute("data-domain"),i.r=n.referrer||null,i.w=window.screen.width||window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=e.props);var a=new XMLHttpRequest;a.open("POST",p,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4===a.readyState&&e&&e.callback&&e.callback()}}}var s=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],l=r.getAttribute("file-types"),d=r.getAttribute("add-file-types"),c=l&&l.split(",")||d&&d.split(",").concat(s)||s;function w(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var n,r=e&&e.href&&e.href.split("?")[0];r&&(n=r.split(".").pop(),c.some(function(t){return t===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){o.href=e.href},150),t.preventDefault()))}n.addEventListener("click",w),n.addEventListener("auxclick",w);var u=window.plausible&&window.plausible.q||[];window.plausible=a;for(var f,v=0;v<u.length;v++)a.apply(this,u[v]);function g(){f!==o.pathname&&(f=o.pathname,a("pageview"))}var h,m=window.history;m.pushState&&(h=m.pushState,m.pushState=function(){h.apply(this,arguments),g()},window.addEventListener("popstate",g)),"prerender"===n.visibilityState?n.addEventListener("visibilitychange",function(){f||"visible"!==n.visibilityState||g()}):g()}();