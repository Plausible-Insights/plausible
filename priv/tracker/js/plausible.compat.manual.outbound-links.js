!function(){"use strict";var t,e,n,c=window.location,r=window.document,i=r.getElementById("plausible"),o=i.getAttribute("data-api")||(t=i.src.split("/"),e=t[0],n=t[2],e+"//"+n+"/api/event");function l(t){console.warn("Ignoring Event: "+t)}function a(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(c.hostname)||"file:"===c.protocol)return l("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return l("localStorage flag")}catch(t){}var n={};n.n=t,n.u=e&&e.u?e.u:c.href,n.d=i.getAttribute("data-domain"),n.r=r.referrer||null,n.w=window.innerWidth,e&&e.meta&&(n.m=JSON.stringify(e.meta)),e&&e.props&&(n.p=e.props);var a=new XMLHttpRequest;a.open("POST",o,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(n)),a.onreadystatechange=function(){4===a.readyState&&e&&e.callback&&e.callback()}}}var s=window.plausible&&window.plausible.q||[];window.plausible=a;for(var u=0;u<s.length;u++)a.apply(this,s[u]);function p(t){if("auxclick"!==t.type||1===t.button){var e,n,a,r,i,o,l=function(t){for(;t&&(void 0===t.tagName||"a"!==t.tagName.toLowerCase()||!t.href);)t=t.parentNode;return t}(t.target);l&&l.href&&l.href.split("?")[0];if((o=l)&&o.href&&o.host&&o.host!==c.host){var s={url:l.href};return r=s,i=!(a="Outbound Link: Click"),void(!function(t,e){if(!t.defaultPrevented){var n=!e.target||e.target.match(/^_(self|parent|top)$/i),a=!(t.ctrlKey||t.metaKey||t.shiftKey)&&"click"===t.type;return n&&a}}(e=t,n=l)?plausible(a,{props:r}):(plausible(a,{props:r,callback:u}),setTimeout(u,5e3),e.preventDefault()))}}function u(){i||(i=!0,window.location=n.href)}}r.addEventListener("click",p),r.addEventListener("auxclick",p)}();