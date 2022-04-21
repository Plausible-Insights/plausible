!function(){"use strict";var e,t,a,o=window.location,l=window.document,s=l.getElementById("plausible"),c=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],a=e[2],t+"//"+a+"/api/event"),u=s&&s.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function r(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(u)for(var a=0;a<u.length;a++)if("pageview"===e&&o.pathname.match(new RegExp("^"+u[a].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var r={};r.n=e,r.u=t&&t.u?t.u:o.href,r.d=s.getAttribute("data-domain"),r.r=l.referrer||null,r.w=window.innerWidth,t&&t.meta&&(r.m=JSON.stringify(t.meta)),t&&t.props&&(r.p=JSON.stringify(t.props));var i=s.getAttributeNames().filter(function(e){return"event"===e.substring(0,5)}),n=r.p&&JSON.parse(r.p)||{};i.forEach(function(e){var t=e.replace("event-",""),a=s.getAttribute(e);n[t]=a}),r.p=n;var p=new XMLHttpRequest;p.open("POST",c,!0),p.setRequestHeader("Content-Type","text/plain"),p.send(JSON.stringify(r)),p.onreadystatechange=function(){4===p.readyState&&t&&t.callback&&t.callback()}}}var i=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],n=s.getAttribute("file-types"),p=s.getAttribute("add-file-types"),f=n&&n.split(",")||p&&p.split(",").concat(i)||i;function g(e){for(var t=e.target,a="auxclick"===e.type&&2===e.which,r="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var i,n=t&&t.href&&t.href.split("?")[0];n&&(i=n.split(".").pop(),f.some(function(e){return e===i}))&&((a||r)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){o.href=t.href},150),e.preventDefault()))}l.addEventListener("click",g),l.addEventListener("auxclick",g);var w=window.plausible&&window.plausible.q||[];window.plausible=r;for(var v=0;v<w.length;v++)r.apply(this,w[v])}();