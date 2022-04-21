!function(){"use strict";var e,t,i,o=window.location,l=window.document,s=l.getElementById("plausible"),c=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),u=s&&s.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(u)for(var i=0;i<u.length;i++)if("pageview"===e&&o.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=e,a.u=o.href,a.d=s.getAttribute("data-domain"),a.r=l.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var n=s.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),r=a.p&&JSON.parse(a.p)||{};n.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);r[t]=i}),a.p=r,a.h=1;var p=new XMLHttpRequest;p.open("POST",c,!0),p.setRequestHeader("Content-Type","text/plain"),p.send(JSON.stringify(a)),p.onreadystatechange=function(){4===p.readyState&&t&&t.callback&&t.callback()}}}var n=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],r=s.getAttribute("file-types"),p=s.getAttribute("add-file-types"),f=r&&r.split(",")||p&&p.split(",").concat(n)||n;function g(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var n,r=t&&t.href&&t.href.split("?")[0];r&&(n=r.split(".").pop(),f.some(function(e){return e===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}l.addEventListener("click",g),l.addEventListener("auxclick",g);var w=window.plausible&&window.plausible.q||[];window.plausible=a;for(var v,h=0;h<w.length;h++)a.apply(this,w[h]);function m(){v=o.pathname,a("pageview")}window.addEventListener("hashchange",m),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){v||"visible"!==l.visibilityState||m()}):m()}();