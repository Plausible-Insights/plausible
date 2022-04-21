!function(){"use strict";var p=window.location,l=window.document,c=l.currentScript,s=c.getAttribute("data-api")||new URL(c.src).origin+"/api/event",u=c&&c.getAttribute("data-exclude").split(",");function f(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return f("localStorage flag")}catch(e){}if(u)for(var r=0;r<u.length;r++)if("pageview"===e&&p.pathname.match(new RegExp("^"+u[r].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return f("exclusion rule");var a={};a.n=e,a.u=t&&t.u?t.u:p.href,a.d=c.getAttribute("data-domain"),a.r=l.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var i=c.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),n=a.p&&JSON.parse(a.p)||{};i.forEach(function(e){var t=e.replace("event-",""),r=c.getAttribute(e);n[t]=r}),a.p=n,a.h=1;var o=new XMLHttpRequest;o.open("POST",s,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function t(e){for(var t=e.target,r="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==p.host&&((r||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){p.href=t.href},150),e.preventDefault()))}l.addEventListener("click",t),l.addEventListener("auxclick",t);var r=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],a=c.getAttribute("file-types"),i=c.getAttribute("add-file-types"),o=a&&a.split(",")||i&&i.split(",").concat(r)||r;function n(e){for(var t=e.target,r="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var i,n=t&&t.href&&t.href.split("?")[0];n&&(i=n.split(".").pop(),o.some(function(e){return e===i}))&&((r||a)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){p.href=t.href},150),e.preventDefault()))}l.addEventListener("click",n),l.addEventListener("auxclick",n);var d=window.plausible&&window.plausible.q||[];window.plausible=e;for(var g=0;g<d.length;g++)e.apply(this,d[g])}();