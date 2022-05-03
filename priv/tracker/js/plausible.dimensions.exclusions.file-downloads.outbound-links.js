!function(){"use strict";var p=window.location,l=window.document,s=l.currentScript,c=s.getAttribute("data-api")||new URL(s.src).origin+"/api/event",u=s&&s.getAttribute("data-exclude").split(",");function d(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(p.hostname)||"file:"===p.protocol)return d("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(t){}if(u)for(var i=0;i<u.length;i++)if("pageview"===t&&p.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=t,a.u=p.href,a.d=s.getAttribute("data-domain"),a.r=l.referrer||null,a.w=window.screen.width||window.innerWidth,e&&e.meta&&(a.m=JSON.stringify(e.meta)),e&&e.props&&(a.p=e.props);var r=s.getAttributeNames().filter(function(t){return"event-"===t.substring(0,6)}),n=a.p||{};r.forEach(function(t){var e=t.replace("event-",""),i=s.getAttribute(t);n[e]=n[e]||i}),a.p=n;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==p.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){p.href=e.href},150),t.preventDefault()))}l.addEventListener("click",e),l.addEventListener("auxclick",e);var i=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],a=s.getAttribute("file-types"),r=s.getAttribute("add-file-types"),o=a&&a.split(",")||r&&r.split(",").concat(i)||i;function n(t){for(var e=t.target,i="auxclick"===t.type&&2===t.which,a="click"===t.type;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;var r,n=e&&e.href&&e.href.split("?")[0];n&&(r=n.split(".").pop(),o.some(function(t){return t===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){p.href=e.href},150),t.preventDefault()))}l.addEventListener("click",n),l.addEventListener("auxclick",n);var f=window.plausible&&window.plausible.q||[];window.plausible=t;for(var h,w=0;w<f.length;w++)t.apply(this,f[w]);function g(){h!==p.pathname&&(h=p.pathname,t("pageview"))}var v,m=window.history;m.pushState&&(v=m.pushState,m.pushState=function(){v.apply(this,arguments),g()},window.addEventListener("popstate",g)),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){h||"visible"!==l.visibilityState||g()}):g()}();