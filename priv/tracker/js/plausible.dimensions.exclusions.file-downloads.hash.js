!function(){"use strict";var p=window.location,l=window.document,s=l.currentScript,c=s.getAttribute("data-api")||new URL(s.src).origin+"/api/event",u=s&&s.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(p.hostname)||"file:"===p.protocol)return d("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(u)for(var i=0;i<u.length;i++)if("pageview"===e&&p.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=e,a.u=p.href,a.d=s.getAttribute("data-domain"),a.r=l.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var r=s.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),n=a.p&&JSON.parse(a.p)||{};r.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);n[t]=i}),a.p=n,a.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}var t=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],i=s.getAttribute("file-types"),a=s.getAttribute("add-file-types"),o=i&&i.split(",")||a&&a.split(",").concat(t)||t;function r(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var r,n=t&&t.href&&t.href.split("?")[0];n&&(r=n.split(".").pop(),o.some(function(e){return e===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){p.href=t.href},150),e.preventDefault()))}l.addEventListener("click",r),l.addEventListener("auxclick",r);var n=window.plausible&&window.plausible.q||[];window.plausible=e;for(var f,g=0;g<n.length;g++)e.apply(this,n[g]);function w(){f=p.pathname,e("pageview")}window.addEventListener("hashchange",w),"prerender"===l.visibilityState?l.addEventListener("visibilitychange",function(){f||"visible"!==l.visibilityState||w()}):w()}();