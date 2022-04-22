!function(){"use strict";var t,e,i,p=window.location,o=window.document,s=o.getElementById("plausible"),l=s.getAttribute("data-api")||(t=s.src.split("/"),e=t[0],i=t[2],e+"//"+i+"/api/event");function a(t,e){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(t){}var i={};i.n=t,i.u=p.href,i.d=s.getAttribute("data-domain"),i.r=o.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var a=s.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),n=i.p&&JSON.parse(i.p)||{};a.forEach(function(t){var e=t.replace("event-",""),i=s.getAttribute(t);n[e]=n[e]||i}),i.p=JSON.stringify(n);var r=new XMLHttpRequest;r.open("POST",l,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4===r.readyState&&e&&e.callback&&e.callback()}}}var n=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],r=s.getAttribute("file-types"),c=s.getAttribute("add-file-types"),d=r&&r.split(",")||c&&c.split(",").concat(n)||n;function u(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var n,r=e&&e.href&&e.href.split("?")[0];r&&(n=r.split(".").pop(),d.some(function(t){return t===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){p.href=e.href},150),t.preventDefault()))}o.addEventListener("click",u),o.addEventListener("auxclick",u);var w=window.plausible&&window.plausible.q||[];window.plausible=a;for(var f,v=0;v<w.length;v++)a.apply(this,w[v]);function g(){f!==p.pathname&&(f=p.pathname,a("pageview"))}var h,m=window.history;m.pushState&&(h=m.pushState,m.pushState=function(){h.apply(this,arguments),g()},window.addEventListener("popstate",g)),"prerender"===o.visibilityState?o.addEventListener("visibilitychange",function(){f||"visible"!==o.visibilityState||g()}):g()}();