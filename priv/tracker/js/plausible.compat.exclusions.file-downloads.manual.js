!function(){"use strict";var e,t,a,o=window.location,n=window.document,l=n.getElementById("plausible"),p=l.getAttribute("data-api")||(e=l.src.split("/"),t=e[0],a=e[2],t+"//"+a+"/api/event"),s=l&&l.getAttribute("data-exclude").split(",");function c(e){console.warn("Ignoring Event: "+e)}function i(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(o.hostname)||"file:"===o.protocol)return c("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"==window.localStorage.plausible_ignore)return c("localStorage flag")}catch(e){}if(s)for(var a=0;a<s.length;a++)if("pageview"==e&&o.pathname.match(new RegExp("^"+s[a].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return c("exclusion rule");var i={};i.n=e,i.u=t&&t.u?t.u:o.href,i.d=l.getAttribute("data-domain"),i.r=n.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props));var r=new XMLHttpRequest;r.open("POST",p,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4==r.readyState&&t&&t.callback&&t.callback()}}}var r=l.getAttribute("file-types"),u=r&&r.split(",")||["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"];function d(e){for(var t,a,i=e.target,r="auxclick"==e.type&&2==e.which,n="click"==e.type;i&&(void 0===i.tagName||"a"!=i.tagName.toLowerCase()||!i.href);)i=i.parentNode;i&&i.href&&(t=i.href,a=t.split(".").pop(),u.some(function(e){return e==a}))&&((r||n)&&plausible("File Download",{props:{url:i.href}}),i.target&&!i.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!n||(setTimeout(function(){o.href=i.href},150),e.preventDefault()))}n.addEventListener("click",d),n.addEventListener("auxclick",d);var f=window.plausible&&window.plausible.q||[];window.plausible=i;for(var w=0;w<f.length;w++)i.apply(this,f[w])}();