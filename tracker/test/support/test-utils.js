const { expect } = require("@playwright/test");

// Mocks an HTTP request call with the given path. Returns a Promise that resolves to the request
// data. If the request is not made, resolves to null after 3 seconds.
const mockRequest = function (page, path) {
  return new Promise((resolve, _reject) => {
    const requestTimeoutTimer = setTimeout(() => resolve(null), 3000)

    page.route(path, (route, request) => {
      clearTimeout(requestTimeoutTimer)
      resolve(request)
      return route.fulfill({ status: 202, contentType: 'text/plain', body: 'ok' })
    })
  })
}

exports.mockRequest = mockRequest

exports.metaKey = function() {
  if (process.platform === 'darwin') {
    return 'Meta'
  } else {
    return 'Control'
  }
}

// Mocks a specified number of HTTP requests with given path. Returns a promise that resolves to a
// list of requests as soon as the specified number of requests is made, or 3 seconds has passed.
const mockManyRequests = function(page, path, numberOfRequests) {
  return new Promise((resolve, _reject) => {
    let requestList = []
    const requestTimeoutTimer = setTimeout(() => resolve(requestList), 3000)

    page.route(path, (route, request) => {
      requestList.push(request)
      if (requestList.length === numberOfRequests) {
        clearTimeout(requestTimeoutTimer)
        resolve(requestList)
      }
      return route.fulfill({ status: 202, contentType: 'text/plain', body: 'ok' })
    })
  })
}

exports.mockManyRequests = mockManyRequests

exports.expectCustomEvent = function (request, eventName, eventProps) {
  const payload = request.postDataJSON()

  expect(payload.n).toEqual(eventName)

  for (const [key, value] of Object.entries(eventProps)) {
    expect(payload.p[key]).toEqual(value)
  }
}

exports.clickPageElementAndExpectEventRequests = async function (page, locatorToClick, expectedBodySubsets, refutedBodySubsets = []) {
  const requestsToExpect = expectedBodySubsets.length
  const requestsToAwait = requestsToExpect + refutedBodySubsets.length
  
  const plausibleRequestMockList = mockManyRequests(page, '/api/event', requestsToAwait)
  await page.click(locatorToClick)
  const requests = await plausibleRequestMockList

  expect(requests.length).toBe(requestsToExpect)

  expectedBodySubsets.forEach((bodySubset) => {
    expect(requests.some((request) => {
      return hasExpectedBodyParams(request, bodySubset)
    })).toBe(true)
  })

  refutedBodySubsets.forEach((bodySubset) => {
    expect(requests.every((request) => {
      return !hasExpectedBodyParams(request, bodySubset)
    })).toBe(true)
  })
}

function hasExpectedBodyParams(request, expectedBodyParams) {
  const body = request.postDataJSON()

  return Object.keys(expectedBodyParams).every((key) => {
    return body[key] === expectedBodyParams[key]
  })
}
