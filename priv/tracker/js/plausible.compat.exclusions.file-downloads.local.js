!function(){"use strict";var e,t,i,p=window.location,r=window.document,o=r.getElementById("plausible"),l=o.getAttribute("data-api")||(e=o.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event"),s=o&&o.getAttribute("data-exclude").split(",");function c(e){console.warn("Ignoring Event: "+e)}function a(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"==window.localStorage.plausible_ignore)return c("localStorage flag")}catch(e){}if(s)for(var i=0;i<s.length;i++)if("pageview"==e&&p.pathname.match(new RegExp("^"+s[i].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return c("exclusion rule");var a={};a.n=e,a.u=p.href,a.d=o.getAttribute("data-domain"),a.r=r.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var n=new XMLHttpRequest;n.open("POST",l,!0),n.setRequestHeader("Content-Type","text/plain"),n.send(JSON.stringify(a)),n.onreadystatechange=function(){4==n.readyState&&t&&t.callback&&t.callback()}}}var n=o.getAttribute("file-types"),d=n&&n.split(",")||["pdf","xlsx","docx","txt","rtf","csv","exe","key","pps","ppt","pptx","7z","pkg","rar","gz","zip","avi","mov","mp4","mpeg","wmv","midi","mp3","wav","wma"];function u(e){for(var t,i,a=e.target,n="auxclick"==e.type&&2==e.which,r="click"==e.type;a&&(void 0===a.tagName||"a"!=a.tagName.toLowerCase()||!a.href);)a=a.parentNode;a&&a.href&&(t=a.href,i=t.split(".").pop(),d.some(function(e){return e==i}))&&((n||r)&&plausible("File Download",{props:{url:a.href}}),a.target&&!a.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!r||(setTimeout(function(){p.href=a.href},150),e.preventDefault()))}r.addEventListener("click",u),r.addEventListener("auxclick",u);var w=window.plausible&&window.plausible.q||[];window.plausible=a;for(var f,g=0;g<w.length;g++)a.apply(this,w[g]);function v(){f!==p.pathname&&(f=p.pathname,a("pageview"))}var h,m=window.history;m.pushState&&(h=m.pushState,m.pushState=function(){h.apply(this,arguments),v()},window.addEventListener("popstate",v)),"prerender"===r.visibilityState?r.addEventListener("visibilitychange",function(){f||"visible"!==r.visibilityState||v()}):v()}();