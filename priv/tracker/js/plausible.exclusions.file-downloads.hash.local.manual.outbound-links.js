!function(){"use strict";var o=window.location,n=window.document,p=n.currentScript,l=p.getAttribute("data-api")||new URL(p.src).origin+"/api/event",c=p&&p.getAttribute("data-exclude").split(",");function s(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return s("localStorage flag")}catch(e){}if(c)for(var a=0;a<c.length;a++)if("pageview"===e&&o.pathname.match(new RegExp("^"+c[a].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return s("exclusion rule");var r={};r.n=e,r.u=t&&t.u?t.u:o.href,r.d=p.getAttribute("data-domain"),r.r=n.referrer||null,r.w=window.screen.width||window.innerWidth,t&&t.meta&&(r.m=JSON.stringify(t.meta)),t&&t.props&&(r.p=t.props),r.h=1;var i=new XMLHttpRequest;i.open("POST",l,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(r)),i.onreadystatechange=function(){4===i.readyState&&t&&t.callback&&t.callback()}}}function t(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==o.host&&((a||r)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}n.addEventListener("click",t),n.addEventListener("auxclick",t);var a=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],r=p.getAttribute("file-types"),i=p.getAttribute("add-file-types"),u=r&&r.split(",")||i&&i.split(",").concat(a)||a;function d(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var i,n=t&&t.href&&t.href.split("?")[0];n&&(i=n.split(".").pop(),u.some(function(e){return e===i}))&&((a||r)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}n.addEventListener("click",d),n.addEventListener("auxclick",d);var f=window.plausible&&window.plausible.q||[];window.plausible=e;for(var w=0;w<f.length;w++)e.apply(this,f[w])}();