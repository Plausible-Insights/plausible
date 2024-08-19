import React from 'react';
import { createRoot } from 'react-dom/client';
import 'url-search-params-polyfill';

import { RouterProvider } from 'react-router-dom';
import { createAppRouter } from './dashboard/router'
import ErrorBoundary from './dashboard/error-boundary'
import * as api from './dashboard/api'
import * as timer from './dashboard/util/realtime-update-timer'
import { filtersBackwardsCompatibilityRedirect } from './dashboard/query';
import SiteContextProvider, { parseSiteFromDataset } from './dashboard/site-context';
import UserContextProvider from './dashboard/user-context'
import ThemeContextProvider from './dashboard/theme-context'

timer.start()

const container = document.getElementById('stats-react-container')

if (container) {
  const site = parseSiteFromDataset(container.dataset)

  const sharedLinkAuth = container.dataset.sharedLinkAuth
  if (sharedLinkAuth) {
    api.setSharedLinkAuth(sharedLinkAuth)
  }

  try {
    filtersBackwardsCompatibilityRedirect(window.location, window.history)
  } catch (e) {
    console.error('Error redirecting in a backwards compatible way', e)
  }
  
  const router = createAppRouter(site);
  const app = (
    <ErrorBoundary>
      <ThemeContextProvider>
        <SiteContextProvider site={site}>
          <UserContextProvider role={container.dataset.currentUserRole} loggedIn={container.dataset.loggedIn === 'true'}>
            <RouterProvider router={router} />
          </UserContextProvider>
        </SiteContextProvider>
      </ThemeContextProvider>
    </ErrorBoundary>
  )

  const root = createRoot(container)
  root.render(app)
}
