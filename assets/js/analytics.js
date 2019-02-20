(function(window, apiHost){
  'use strict';

  try {
    function setCookie(name,value,minutes) {
        var expires = "";
        if (minutes) {
            var date = new Date();
            date.setTime(date.getTime() + (minutes*60*1000));
            expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "")  + expires + "; path=/";
    }

    function getCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1,c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
        }
        return null;
    }

    function pseudoUUIDv4() {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
      });
    }

    function ignore(reason) {
      if (console && console.warn) console.warn('[Plausible] Ignoring pageview because ' + reason);
    }

    function page() {
      var userAgent = window.navigator.userAgent;
      var referrer = window.document.referrer;
      var screenWidth = window.screen.width;
      var screenHeight = window.screen.height;

      // Ignore prerendered pages
      if( 'visibilityState' in window.document && window.document.visibilityState === 'prerender' ) return ignore('document is prerendering');
      // Ignore locally server pages
      if (window.location.hostname === 'localhost') return ignore('website is running locally');
      // Basic bot detection.
      if (userAgent && userAgent.search(/(bot|spider|crawl)/ig) > -1) return ignore('the user-agent is a bot');

      var existingUid = getCookie('nm_uid');
      var uid = existingUid || pseudoUUIDv4();
      var sid = getCookie('nm_sid') || pseudoUUIDv4();

      var url = window.location.protocol + '//' + window.location.hostname + window.location.pathname;
      var postBody = {
        url: url,
        new_visitor: !existingUid,
        uid: uid,
        sid: sid
      };

      if (userAgent) postBody.user_agent = userAgent;
      if (referrer) postBody.referrer = referrer;
      if (screenWidth) postBody.screen_width = screenWidth;
      if (screenHeight) postBody.screen_height = screenHeight;

      var request = new XMLHttpRequest();
      request.open('POST', apiHost + '/api/page', true);
      request.setRequestHeader('Content-Type', 'text/plain; charset=UTF-8');
      request.send(JSON.stringify(postBody));
        request.onreadystatechange = function() {
          if (request.readyState == XMLHttpRequest.DONE) {
            if (!existingUid) {
              setCookie('nm_uid', uid)
            }
            setCookie('nm_sid', sid, 30)
          }
        }
      }

    page()
  } catch (e) {
    var url = apiHost + '/api/error';
    if (e && e.message) url = url + '?message=' + encodeURIComponent(e.message);
    new Image().src = url;
    throw e
  }
})(window, BASE_URL);
