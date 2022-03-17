!function(){"use strict";var p=window.location,n=window.document,r=n.currentScript,o=r.getAttribute("data-api")||new URL(r.src).origin+"/api/event";function l(t){console.warn("Ignoring Event: "+t)}function t(t,e){if(/^localhost$|^127(\.[0-9]+){0,2}\.[0-9]+$|^\[::1?\]$/.test(p.hostname)||"file:"===p.protocol)return l("localhost");if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"==window.localStorage.plausible_ignore)return l("localStorage flag")}catch(t){}var i={};i.n=t,i.u=p.href,i.d=r.getAttribute("data-domain"),i.r=n.referrer||null,i.w=window.innerWidth,e&&e.meta&&(i.m=JSON.stringify(e.meta)),e&&e.props&&(i.p=JSON.stringify(e.props));var a=new XMLHttpRequest;a.open("POST",o,!0),a.setRequestHeader("Content-Type","text/plain"),a.send(JSON.stringify(i)),a.onreadystatechange=function(){4==a.readyState&&e&&e.callback&&e.callback()}}}function e(t){for(var e=t.target,i="auxclick"==t.type&&2==t.which,a="click"==t.type;e&&(void 0===e.tagName||"a"!=e.tagName.toLowerCase()||!e.href);)e=e.parentNode;e&&e.href&&e.host&&e.host!==p.host&&((i||a)&&plausible("Outbound Link: Click",{props:{url:e.href}}),e.target&&!e.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!a||(setTimeout(function(){p.href=e.href},150),t.preventDefault()))}n.addEventListener("click",e),n.addEventListener("auxclick",e);var s=r.getAttribute("file-types")||[".pdf",".xlsx",".docx",".txt",".rtf",".csv",".exe",".key",".pps",".ppt",".pptx",".7z",".pkg",".rar",".gz",".zip",".avi",".mov",".mp4",".mpeg",".wmv",".midi",".mp3",".wav",".wma"];function i(t){for(var e,i,a,n=t.target,r="auxclick"==t.type&&2==t.which,o="click"==t.type;n&&(void 0===n.tagName||"a"!=n.tagName.toLowerCase()||!n.href);)n=n.parentNode;n&&n.href&&(e=n.href,i=e.split("/"),a=i[i.length-1].match(/\.[0-9a-z]+$/i)[0],s.includes(a))&&((r||o)&&plausible("File Download",{props:{url:n.href}}),n.target&&!n.target.match(/^_(self|parent|top)$/i)||t.ctrlKey||t.metaKey||t.shiftKey||!o||(setTimeout(function(){p.href=n.href},150),t.preventDefault()))}n.addEventListener("click",i),n.addEventListener("auxclick",i);var a=window.plausible&&window.plausible.q||[];window.plausible=t;for(var c,d=0;d<a.length;d++)t.apply(this,a[d]);function u(){c!==p.pathname&&(c=p.pathname,t("pageview"))}var f,h=window.history;h.pushState&&(f=h.pushState,h.pushState=function(){f.apply(this,arguments),u()},window.addEventListener("popstate",u)),"prerender"===n.visibilityState?n.addEventListener("visibilitychange",function(){c||"visible"!==n.visibilityState||u()}):u()}();