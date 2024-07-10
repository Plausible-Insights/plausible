import React from 'react';
import { createRoot } from 'react-dom/client';
import 'url-search-params-polyfill';

import Router from './dashboard/router'
import ErrorBoundary from './dashboard/error-boundary'
import * as api from './dashboard/api'
import * as timer from './dashboard/util/realtime-update-timer'
import { filtersBackwardsCompatibilityRedirect } from './dashboard/query';
import SiteContextProvider, { parseSiteFromDataset } from './dashboard/site-context';
import UserContextProvider from './dashboard/user-context'

timer.start()

const container = document.getElementById('stats-react-container')

if (container) {
  const site = parseSiteFromDataset(container.dataset)

  const sharedLinkAuth = container.dataset.sharedLinkAuth
  if (sharedLinkAuth) {
    api.setSharedLinkAuth(sharedLinkAuth)
  }

  filtersBackwardsCompatibilityRedirect()

  const app = (
    <ErrorBoundary>
      <SiteContextProvider site={site}>
        <UserContextProvider role={container.dataset.currentUserRole} loggedIn={container.dataset.loggedIn === 'true'}>
          <Router />
        </UserContextProvider>
      </SiteContextProvider>
    </ErrorBoundary>
  )

  const root = createRoot(container)
  root.render(app)
}
