!function(){"use strict";var e,t,i,p=window.location,u=window.document,c=u.getElementById("plausible"),d=c.getAttribute("data-api")||(e=c.src.split("/"),t=e[0],i=e[2],t+"//"+i+"/api/event");function f(e){console.warn("Ignoring Event: "+e)}function a(e,t){try{if("true"===window.localStorage.plausible_ignore)return f("localStorage flag")}catch(e){}var i=c&&c.getAttribute("data-include"),a=c&&c.getAttribute("data-exclude");if("pageview"===e){var n=!i||i&&i.split(",").some(o),r=a&&a.split(",").some(o);if(!n||r)return f("exclusion rule")}function o(e){return p.pathname.match(new RegExp("^"+e.trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$"))}var l={};l.n=e,l.u=p.href,l.d=c.getAttribute("data-domain"),l.r=u.referrer||null,l.w=window.innerWidth,t&&t.meta&&(l.m=JSON.stringify(t.meta)),t&&t.props&&(l.p=t.props);var s=new XMLHttpRequest;s.open("POST",d,!0),s.setRequestHeader("Content-Type","text/plain"),s.send(JSON.stringify(l)),s.onreadystatechange=function(){4===s.readyState&&t&&t.callback&&t.callback()}}var n=window.plausible&&window.plausible.q||[];window.plausible=a;for(var r,o=0;o<n.length;o++)a.apply(this,n[o]);function l(){r!==p.pathname&&(r=p.pathname,a("pageview"))}var s,h=window.history;function v(e){if("auxclick"!==e.type||1===e.button){var t,i,a,n,r,o,l=function(e){for(;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;return e}(e.target);l&&l.href&&l.href.split("?")[0];if((o=l)&&o.href&&o.host&&o.host!==p.host){var s={url:l.href};return n=s,r=!(a="Outbound Link: Click"),void(!function(e,t){if(!e.defaultPrevented){var i=!t.target||t.target.match(/^_(self|parent|top)$/i),a=!(e.ctrlKey||e.metaKey||e.shiftKey)&&"click"===e.type;return i&&a}}(t=e,i=l)?plausible(a,{props:n}):(plausible(a,{props:n,callback:u}),setTimeout(u,5e3),t.preventDefault()))}}function u(){r||(r=!0,window.location=i.href)}}h.pushState&&(s=h.pushState,h.pushState=function(){s.apply(this,arguments),l()},window.addEventListener("popstate",l)),"prerender"===u.visibilityState?u.addEventListener("visibilitychange",function(){r||"visible"!==u.visibilityState||l()}):l(),u.addEventListener("click",v),u.addEventListener("auxclick",v)}();