!function(){"use strict";var s=window.location,c=window.document,p=c.currentScript,d=p.getAttribute("data-api")||new URL(p.src).origin+"/api/event";function f(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(s.hostname)||"file:"===s.protocol)return f("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"===window.localStorage.plausible_ignore)return f("localStorage flag")}catch(e){}var r=p&&p.getAttribute("data-include"),a=p&&p.getAttribute("data-exclude");if("pageview"===e){var n=!r||r&&r.split(",").some(u),i=a&&a.split(",").some(u);if(!n||i)return f("exclusion rule")}var o={};o.n=e,o.u=t&&t.u?t.u:s.href,o.d=p.getAttribute("data-domain"),o.r=c.referrer||null,o.w=window.innerWidth,t&&t.meta&&(o.m=JSON.stringify(t.meta)),t&&t.props&&(o.p=t.props),o.h=1;var l=new XMLHttpRequest;l.open("POST",d,!0),l.setRequestHeader("Content-Type","text/plain"),l.send(JSON.stringify(o)),l.onreadystatechange=function(){4===l.readyState&&t&&t.callback&&t.callback()}}function u(e){var t=s.pathname;return(t+=s.hash).match(new RegExp("^"+e.trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$"))}}var t=window.plausible&&window.plausible.q||[];window.plausible=e;for(var r=0;r<t.length;r++)e.apply(this,t[r]);function a(e){if("auxclick"!==e.type||1===e.button){var t,r,a,n,i,o,l=function(e){for(;e&&(void 0===e.tagName||"a"!==e.tagName.toLowerCase()||!e.href);)e=e.parentNode;return e}(e.target);l&&l.href&&l.href.split("?")[0];if((o=l)&&o.href&&o.host&&o.host!==s.host){var u={url:l.href};return n=u,i=!(a="Outbound Link: Click"),void(!function(e,t){if(!e.defaultPrevented){var r=!t.target||t.target.match(/^_(self|parent|top)$/i),a=!(e.ctrlKey||e.metaKey||e.shiftKey)&&"click"===e.type;return r&&a}}(t=e,r=l)?plausible(a,{props:n}):(plausible(a,{props:n,callback:c}),setTimeout(c,5e3),t.preventDefault()))}}function c(){i||(i=!0,window.location=r.href)}}c.addEventListener("click",a),c.addEventListener("auxclick",a)}();