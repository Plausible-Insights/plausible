!function(){"use strict";var p=window.location,n=window.document,o=n.currentScript,l=o.getAttribute("data-api")||new URL(o.src).origin+"/api/event",c=o&&o.getAttribute("data-exclude").split(",");function s(e){console.warn("Ignoring Event: "+e)}function e(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"==window.localStorage.plausible_ignore)return s("localStorage flag")}catch(e){}if(c)for(var a=0;a<c.length;a++)if("pageview"==e&&p.pathname.match(new RegExp("^"+c[a].trim().replace(/\*\*/g,".*").replace(/([^\.])\*/g,"$1[^\\s/]*")+"/?$")))return s("exclusion rule");var i={};i.n=e,i.u=t&&t.u?t.u:p.href,i.d=o.getAttribute("data-domain"),i.r=n.referrer||null,i.w=window.innerWidth,t&&t.meta&&(i.m=JSON.stringify(t.meta)),t&&t.props&&(i.p=JSON.stringify(t.props));var r=new XMLHttpRequest;r.open("POST",l,!0),r.setRequestHeader("Content-Type","text/plain"),r.send(JSON.stringify(i)),r.onreadystatechange=function(){4==r.readyState&&t&&t.callback&&t.callback()}}}var u=o.getAttribute("file-types")||[".pdf",".xlsx",".docx",".txt",".rtf",".csv",".exe",".key",".pps",".ppt",".pptx",".7z",".pkg",".rar",".gz",".zip",".avi",".mov",".mp4",".mpeg",".wmv",".midi",".mp3",".wav",".wma"];function t(e){for(var t,a,i,r=e.target,n="auxclick"==e.type&&2==e.which,o="click"==e.type;r&&(void 0===r.tagName||"a"!=r.tagName.toLowerCase()||!r.href);)r=r.parentNode;r&&r.href&&(t=r.href,a=t.split("/"),i=a[a.length-1].match(/\.[0-9a-z]+$/i)[0],u.includes(i))&&((n||o)&&plausible("File Download",{props:{url:r.href}}),r.target&&!r.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!o||(setTimeout(function(){p.href=r.href},150),e.preventDefault()))}n.addEventListener("click",t),n.addEventListener("auxclick",t);var a=window.plausible&&window.plausible.q||[];window.plausible=e;for(var i=0;i<a.length;i++)e.apply(this,a[i])}();