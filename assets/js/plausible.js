(function(window, plausibleHost){
  'use strict';

  try {
    const scriptEl = window.document.querySelector('[src*="' + plausibleHost +'"]')
    const domainAttr = scriptEl && scriptEl.getAttribute('data-domain')

    const CONFIG = {
      domain: domainAttr || window.location.hostname
    }

    function setCookie(name,value) {
      var date = new Date();
      date.setTime(date.getTime() + (3*365*24*60*60*1000)); // 3 YEARS
      var expires = "; expires=" + date.toUTCString();
      document.cookie = name + "=" + (value || "")  + expires + "; samesite=strict; path=/";
    }

    function getCookie(name) {
      let matches = document.cookie.match(new RegExp(
        "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"
      ));
      return matches ? decodeURIComponent(matches[1]) : null;
    }

    function pseudoUUIDv4() {
      var d = new Date().getTime();
      if (typeof performance !== 'undefined' && typeof performance.now === 'function'){
        d += performance.now(); //use high-precision timer if available
      }
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = (d + Math.random() * 16) % 16 | 0;
        d = Math.floor(d / 16);
        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
      });
    }

    function ignore(reason) {
      console.warn('[Plausible] Ignoring event because ' + reason);
    }

    function getUrl() {
      return window.location.protocol + '//' + window.location.hostname + window.location.pathname + window.location.search;
    }

    function getSourceFromQueryParam() {
      const result = window.location.search.match(/[?&](ref|source|utm_source)=([^?&]+)/);
      return result ? result[2] : null
    }

    function getUserData() {
      var userData = JSON.parse(getCookie('plausible_user'))

      if (userData) {
        userData.new_visitor = false
        if (userData.referrer) {
          userData.initial_referrer = userData.referrer && decodeURIComponent(userData.referrer)
        } else {
          userData.initial_referrer = userData.initial_referrer && decodeURIComponent(userData.initial_referrer)
          userData.initial_source = userData.initial_source && decodeURIComponent(userData.initial_source)
        }
        return userData
      } else {
        return {
          uid: pseudoUUIDv4(),
          new_visitor: true,
          initial_referrer: window.document.referrer,
          initial_source: getSourceFromQueryParam(),
        }
      }
    }

    function setUserData(payload) {
      setCookie('plausible_user', JSON.stringify({
        uid: payload.uid,
        initial_referrer: payload.initial_referrer && encodeURIComponent(payload.initial_referrer),
        initial_source: payload.initial_source && encodeURIComponent(payload.initial_source),
      }))
    }

    function trigger(eventName, options) {
      if (/localhost$/.test(window.location.hostname)) return ignore('website is running locally');
      if (window.location.protocol === 'file:') return ignore('website is running locally');
      if (window.document.visibilityState === 'prerender') return ignore('document is prerendering');

      var payload = getUserData()
      payload.name = eventName
      payload.url = getUrl()
      payload.domain = CONFIG['domain']
      payload.referrer = window.document.referrer
      payload.source = getSourceFromQueryParam()
      payload.user_agent = window.navigator.userAgent
      payload.screen_width = window.innerWidth

      var request = new XMLHttpRequest();
      request.open('POST', plausibleHost + '/api/event', true);
      request.setRequestHeader('Content-Type', 'text/plain');

      request.send(JSON.stringify(payload));

      request.onreadystatechange = function() {
        if (request.readyState == XMLHttpRequest.DONE) {
          setUserData(payload)
          options && options.callback && options.callback()
        }
      }
    }

    function onUnload() {
      var userData = getUserData()
      navigator.sendBeacon(plausibleHost + '/api/unload', JSON.stringify({
        uid: userData.uid,
        domain: CONFIG['domain']
      }));
    }

    function page() {
      trigger('pageview')
      window.addEventListener('unload', onUnload, false);
    }

    var his = window.history
    if (his.pushState) {
      var originalPushState = his['pushState']
      his.pushState = function() {
        originalPushState.apply(this, arguments)
        page();
      }
      window.addEventListener('popstate', page)
    }

    const queue = (window.plausible && window.plausible.q) || []
    window.plausible = trigger
    for (var i = 0; i < queue.length; i++) {
      trigger.apply(this, queue[i])
    }

    page()
  } catch (e) {
    new Image().src = plausibleHost + '/api/error?message=' +  encodeURIComponent(e.message);
  }
})(window, BASE_URL);
