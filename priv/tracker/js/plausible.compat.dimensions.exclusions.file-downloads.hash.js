!function(){"use strict";var e,t,i,l=window.location,p=window.document,s=p.getElementById("plausible"),c=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),d=s&&s.getAttribute("data-exclude").split(",");function u(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(l.hostname)||"file:"===l.protocol)return u("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return u("localStorage flag")}catch(e){}if(d)for(var i=0;i<d.length;i++)if("pageview"===e&&l.pathname.match(new RegExp("^"+d[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return u("exclusion rule");var a={};a.n=e,a.u=l.href,a.d=s.getAttribute("data-domain"),a.r=p.referrer||null,a.w=window.screen.width||window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=t.props);var n=s.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),r=a.p||{};n.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);r[t]=r[t]||i}),a.p=r,a.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var n=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],r=s.getAttribute("file-types"),o=s.getAttribute("add-file-types"),w=r&&r.split(",")||o&&o.split(",").concat(n)||n;function f(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var n,r=t&&t.href&&t.href.split("?")[0];r&&(n=r.split(".").pop(),w.some(function(e){return e===n}))&&((i||a)&&plausible("File Download",{props:{url:r}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}p.addEventListener("click",f),p.addEventListener("auxclick",f);var g=window.plausible&&window.plausible.q||[];window.plausible=a;for(var v,h=0;h<g.length;h++)a.apply(this,g[h]);function m(){v=l.pathname,a("pageview")}window.addEventListener("hashchange",m),"prerender"===p.visibilityState?p.addEventListener("visibilitychange",function(){v||"visible"!==p.visibilityState||m()}):m()}();