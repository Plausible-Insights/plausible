!function(){"use strict";var p=window.location,r=window.document,n=r.currentScript,o=n.getAttribute("data-api")||new URL(n.src).origin+"/api/event";function e(e,t){if(!(window._phantom||window.__nightmare||window.navigator.webdriver||window.Cypress)){try{if("true"==window.localStorage.plausible_ignore)return void console.warn("Ignoring Event: localStorage flag")}catch(e){}var a={};a.n=e,a.u=t&&t.u?t.u:p.href,a.d=n.getAttribute("data-domain"),a.r=r.referrer||null,a.w=window.innerWidth,t&&t.meta&&(a.m=JSON.stringify(t.meta)),t&&t.props&&(a.p=JSON.stringify(t.props));var i=new XMLHttpRequest;i.open("POST",o,!0),i.setRequestHeader("Content-Type","text/plain"),i.send(JSON.stringify(a)),i.onreadystatechange=function(){4==i.readyState&&t&&t.callback&&t.callback()}}}var l=n.getAttribute("file-types")||[".pdf",".xlsx",".docx",".txt",".rtf",".csv",".exe",".key",".pps",".ppt",".pptx",".7z",".pkg",".rar",".gz",".zip",".avi",".mov",".mp4",".mpeg",".wmv",".midi",".mp3",".wav",".wma"];function t(e){for(var t,a,i,r=e.target,n="auxclick"==e.type&&2==e.which,o="click"==e.type;r&&(void 0===r.tagName||"a"!=r.tagName.toLowerCase()||!r.href);)r=r.parentNode;r&&r.href&&(t=r.href,a=t.split("/"),i=a[a.length-1].match(/\.[0-9a-z]+$/i)[0],l.includes(i))&&((n||o)&&plausible("File Download",{props:{url:r.href}}),r.target&&!r.target.match(/^_(self|parent|top)$/i)||e.ctrlKey||e.metaKey||e.shiftKey||!o||(setTimeout(function(){p.href=r.href},150),e.preventDefault()))}r.addEventListener("click",t),r.addEventListener("auxclick",t);var a=window.plausible&&window.plausible.q||[];window.plausible=e;for(var i=0;i<a.length;i++)e.apply(this,a[i])}();