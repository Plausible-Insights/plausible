!function(){"use strict";var e,t,i,l=window.location,p=window.document,s=p.getElementById("plausible"),c=s.getAttribute("data-api")||(e=s.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),u=s&&s.getAttribute("data-exclude").split(",");function d(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return d("localStorage flag")}catch(e){}if(u)for(var i=0;i<u.length;i++)if("pageview"===e&&l.pathname.match(new RegExp("^"+u[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return d("exclusion rule");var a={};a.n=e,a.u=l.href,a.d=s.getAttribute("data-domain"),a.r=p.referrer||null,a.w=window.screen.width||window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=t.props);var r=s.getAttributeNames().filter(function(e){return"event-"===e.substring(0,6)}),n=a.p||{};r.forEach(function(e){var t=e.replace("event-",""),i=s.getAttribute(e);n[t]=n[t]||i}),a.p=n,a.h=1;var o=new XMLHttpRequest;o.open("POST",c,!0),o.setRequestHeader("Content-Type","text/plain"),o.send(JSON.stringify(a)),o.onreadystatechange=function(){4===o.readyState&&t&&t.callback&&t.callback()}}}function r(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;t&&t.href&&t.host&&t.host!==l.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:t.href}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}p.addEventListener("click",r),p.addEventListener("auxclick",r);var n=["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"],o=s.getAttribute("file-types"),f=s.getAttribute("add-file-types"),g=o&&o.split(",")||f&&f.split(",").concat(n)||n;function w(e){for(var t=e.target,i="auxclick"===e.type&&2===e.which,a="click"===e.type;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;var r,n=t&&t.href&&t.href.split("?")[0];n&&(r=n.split(".").pop(),g.some(function(e){return e===r}))&&((i||a)&&plausible("File Download",{props:{url:n}}),t.target&&!t.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!a||(setTimeout(function(){l.href=t.href},150),e.preventDefault()))}p.addEventListener("click",w),p.addEventListener("auxclick",w);var h=window.plausible&&window.plausible.q||[];window.plausible=a;for(var v,m=0;m<h.length;m++)a.apply(this,h[m]);function y(){v=l.pathname,a("pageview")}window.addEventListener("hashchange",y),"prerender"===p.visibilityState?p.addEventListener("visibilitychange",function(){v||"visible"!==p.visibilityState||y()}):y()}();