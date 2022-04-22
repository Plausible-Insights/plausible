!function(){"use strict";var l=window.location,p=window.document,s=p.currentScript,c=s.getAttribute("data-api")||new URL(s.src).origin+"/api/event",u=s&&s.getAttribute("data-exclude").split(",");function f(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(l.hostname)||"file:"===l.protocol)return f("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return f("localStorage flag")}catch(e){}if(u)for(var i=0;i<u.length;i++)if("pageview"===e&&l.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return f("exclusion rule");var a={};a.n=e,a.u=l.href,a.d=s.getAttribute("data-domain"),a.r=p.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var r=s.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),n=a.p&&JSON.parse(a.p)||{};r.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);n[t]=n[t]||i}),a.p=JSON.stringify(n),a.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function t(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==l.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}p.addEventListener("click",t),p.addEventListener("auxclick",t);var i=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],a=s.getAttribute("file-types"),r=s.getAttribute("add-file-types"),o=a&&a.split(",")||r&&r.split(",").concat(i)||i;function n(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var r,n=t&&t.href&&t.href.split("?")[0];n&&(r=n.split(".").pop(),o.some(function(e){return e===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}p.addEventListener("click",n),p.addEventListener("auxclick",n);var d=window.plausible&&window.plausible.q||[];window.plausible=e;for(var g,h=0;h<d.length;h++)e.apply(this,d[h]);function w(){g=l.pathname,e("pageview")}window.addEventListener("hashchange",w),"prerender"===p.visibilityState?p.addEventListener("visibilitychange",function(){g||"visible"!==p.visibilityState||w()}):w()}();