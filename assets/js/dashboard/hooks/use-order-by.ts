/** @format */

import { useCallback, useMemo, useState } from 'react'
import { Metric } from '../stats/reports/metrics'

export enum SortDirection {
  asc = 'asc',
  desc = 'desc'
}

export type Order = [Metric['key'], SortDirection]

export type OrderBy = Order[]

export const getSortDirectionLabel = (sortDirection: SortDirection): string =>
  ({
    [SortDirection.asc]: 'Sorted in ascending order',
    [SortDirection.desc]: 'Sorted in descending order'
  })[sortDirection]

export function useOrderBy({
  metrics,
  defaultOrderBy
}: {
  metrics: Pick<Metric, 'key'>[]
  defaultOrderBy: OrderBy
}) {
  const [orderBy, setOrderBy] = useState<OrderBy>([])
  const orderByDictionary: Record<Metric['key'], SortDirection> = useMemo(
    () =>
      orderBy.length
        ? Object.fromEntries(orderBy)
        : Object.fromEntries(defaultOrderBy),
    [orderBy, defaultOrderBy]
  )

  const toggleSortByMetric = useCallback(
    (metric: Pick<Metric, 'key'>) => {
      if (!metrics.find(({ key }) => key === metric.key)) {
        return
      }
      setOrderBy((currentOrderBy) =>
        rearrangeOrderBy(
          currentOrderBy.length ? currentOrderBy : defaultOrderBy,
          metric
        )
      )
    },
    [metrics, defaultOrderBy]
  )

  return {
    orderBy: orderBy.length ? orderBy : defaultOrderBy,
    orderByDictionary,
    toggleSortByMetric
  }
}

export function cycleSortDirection(
  currentSortDirection: SortDirection | null
): { direction: SortDirection; hint: string } {
  switch (currentSortDirection) {
    case null:
    case SortDirection.asc:
      return {
        direction: SortDirection.desc,
        hint: 'Press to sort column in descending order'
      }
    case SortDirection.desc:
      return {
        direction: SortDirection.asc,
        hint: 'Press to sort column in ascending order'
      }
  }
}

export function findOrderIndex(orderBy: OrderBy, metric: Pick<Metric, 'key'>) {
  return orderBy.findIndex(([metricKey]) => metricKey === metric.key)
}

export function rearrangeOrderBy(
  currentOrderBy: OrderBy,
  metric: Pick<Metric, 'key'>
): OrderBy {
  const orderIndex = findOrderIndex(currentOrderBy, metric)
  if (orderIndex < 0) {
    const sortDirection = cycleSortDirection(null).direction as SortDirection
    return [[metric.key, sortDirection]]
  }
  const previousOrder = currentOrderBy[orderIndex]
  const sortDirection = cycleSortDirection(previousOrder[1]).direction
  if (sortDirection === null) {
    return []
  }
  return [[metric.key, sortDirection]]
}
