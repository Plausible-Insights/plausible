/** @format */

import React, { useEffect, useMemo, useRef, useState } from 'react'
import {
  DropdownLinkGroup,
  DropdownMenuWrapper,
  DropdownNavigationLink,
  DropdownSubtitle,
  ToggleDropdownButton
} from '../components/dropdown'
import { MagnifyingGlassIcon } from '@heroicons/react/20/solid'
import {
  cleanLabels,
  FILTER_MODAL_TO_FILTER_GROUP,
  formatFilterGroup,
  remapToApiFilters
} from '../util/filters'
import { PlausibleSite, useSiteContext } from '../site-context'
import { editSegmentRoute, filterRoute, rootRoute } from '../router'
import { useOnClickOutside } from '../util/use-on-click-outside'
import {
  SegmentActionsList,
  SegmentsList,
  useGetSegmentById
} from '../segments/segments-dropdown'
import { useQueryContext } from '../query-context'
import {
  CreateSegmentModal,
  DeleteSegmentModal,
  UpdateSegmentModal
} from '../segments/segment-modals'
import { useUserContext } from '../user-context'
import {
  formatSegmentIdAsLabelKey,
  getSegmentNamePlaceholder,
  parseApiSegmentData,
  SavedSegment
} from '../segments/segments'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { useAppNavigate } from '../navigation/use-app-navigate'
import { DashboardQuery } from '../query'
import { AdjustmentsHorizontalIcon } from '@heroicons/react/24/solid'
import { useMatch } from 'react-router-dom'

export function getFilterListItems({
  propsAvailable
}: Pick<PlausibleSite, 'propsAvailable'>): Array<
  Array<{
    title: string
    modals: Array<false | keyof typeof FILTER_MODAL_TO_FILTER_GROUP>
  }>
> {
  return [
    [
      {
        title: 'URL',
        modals: ['page', 'hostname']
      },
      {
        title: 'Acquisition',
        modals: ['source', 'utm']
      }
    ],
    [
      {
        title: 'Device',
        modals: ['location', 'screen', 'browser', 'os']
      },
      {
        title: 'Behaviour',
        modals: ['goal', !!propsAvailable && 'props']
      }
    ]
  ]
}

export const FilterMenu = () => {
  const match = useMatch(editSegmentRoute.path)
  const expandedSegmentId = match ? parseInt(match.params.id!, 10) : null
  const [modal, setModal] = useState<'update' | 'create' | 'delete' | null>(
    null
  )
  useEffect(() => {
    setModal(null)
  }, [match])
  const s = useGetSegmentById({ id: expandedSegmentId! })
  const expandedSegment = s.data
  const user = useUserContext()
  const dropdownRef = useRef<HTMLDivElement>(null)
  const [opened, setOpened] = useState(false)
  const site = useSiteContext()
  const { query } = useQueryContext()

  const queryClient = useQueryClient()
  const navigate = useAppNavigate()
  const patchSegment = useMutation({
    mutationFn: ({
      id,
      name,
      type,
      segment_data
    }: Pick<SavedSegment, 'id'> &
      Partial<Pick<SavedSegment, 'name' | 'type'>> & {
        segment_data?: {
          filters: DashboardQuery['filters']
          labels: DashboardQuery['labels']
        }
      }) => {
      return fetch(
        `/internal-api/${encodeURIComponent(site.domain)}/segments/${id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({
            name,
            type,
            ...(segment_data && {
              segment_data: {
                filters: remapToApiFilters(segment_data.filters),
                labels: cleanLabels(segment_data.filters, segment_data.labels)
              }
            })
          }),
          headers: {
            'content-type': 'application/json',
            accept: 'application/json'
          }
        }
      )
        .then((res) => res.json())
        .then((d) => ({
          ...d,
          segment_data: parseApiSegmentData(d.segment_data)
        }))
    },
    onSuccess: async (d) => {
      queryClient.invalidateQueries({ queryKey: ['segments'] })
      navigate({
        path: rootRoute.path,
        search: (search) => {
          const filters = [['is', 'segment', [d.id]]]
          const labels = cleanLabels(filters, {}, 'segment', {
            [formatSegmentIdAsLabelKey(d.id)]: d.name
          })
          return {
            ...search,
            filters,
            labels
          }
        }
      })
      setOpened(false)
      setModal(null)
    }
  })

  const createSegment = useMutation({
    mutationFn: ({
      name,
      type,
      segment_data
    }: {
      name: string
      type: 'personal' | 'site'
      segment_data: {
        filters: DashboardQuery['filters']
        labels: DashboardQuery['labels']
      }
    }) => {
      return fetch(
        `/internal-api/${encodeURIComponent(site.domain)}/segments`,
        {
          method: 'POST',
          body: JSON.stringify({
            name,
            type,
            segment_data: {
              filters: remapToApiFilters(segment_data.filters),
              labels: cleanLabels(segment_data.filters, segment_data.labels)
            }
          }),
          headers: { 'content-type': 'application/json' }
        }
      )
        .then((res) => res.json())
        .then((d) => ({
          ...d,
          segment_data: parseApiSegmentData(d.segment_data)
        }))
    },
    onSuccess: async (d) => {
      navigate({
        path: rootRoute.path,
        search: (search) => {
          queryClient.invalidateQueries({ queryKey: ['segments'] })
          const filters = [['is', 'segment', [d.id]]]
          const labels = cleanLabels(filters, {}, 'segment', {
            [formatSegmentIdAsLabelKey(d.id)]: d.name
          })
          return {
            ...search,
            filters,
            labels
          }
        }
      })
      setOpened(false)
      setModal(null)
    }
  })
  const deleteSegment = useMutation({
    mutationFn: (data: Pick<SavedSegment, 'id'>) => {
      return fetch(
        `/internal-api/${encodeURIComponent(site.domain)}/segments/${data.id}`,
        {
          method: 'DELETE'
        }
      )
        .then((res) => res.json())
        .then((d) => ({
          ...d,
          segment_data: parseApiSegmentData(d.segment_data)
        }))
    },
    onSuccess: (_d): void => {
      queryClient.invalidateQueries({ queryKey: ['segments'] })
      navigate({
        path: rootRoute.path,
        search: (s) => {
          return {
            ...s,
            filters: null,
            labels: null
          }
        }
      })
      setOpened(false)
      setModal(null)
    }
  })

  useOnClickOutside({
    ref: dropdownRef,
    active: opened && modal === null,
    handler: () => setOpened(false)
  })

  return (
    <>
      {user.loggedIn && modal === 'update' && expandedSegment && (
        <UpdateSegmentModal
          canTogglePersonal={['admin', 'owner', 'super_admin'].includes(
            user.role
          )}
          segment={expandedSegment}
          namePlaceholder={getSegmentNamePlaceholder(query)}
          close={() => setModal(null)}
          onSave={({ id, name, type }) =>
            patchSegment.mutate({
              id,
              name,
              type,
              segment_data: {
                filters: query.filters,
                labels: query.labels
              }
            })
          }
        />
      )}
      {user.loggedIn && modal === 'create' && (
        <CreateSegmentModal
          canTogglePersonal={['admin', 'owner', 'super_admin'].includes(
            user.role
          )}
          segment={expandedSegment!}
          namePlaceholder={getSegmentNamePlaceholder(query)}
          onClose={() => setModal(null)}
          onSave={({ name, type }) =>
            createSegment.mutate({
              name,
              type,
              segment_data: {
                filters: query.filters,
                labels: query.labels
              }
            })
          }
        />
      )}
      {user.loggedIn && modal === 'delete' && expandedSegment && (
        <DeleteSegmentModal
          segment={expandedSegment}
          onClose={() => setModal(null)}
          onSave={({ id }) => deleteSegment.mutate({ id })}
        />
      )}

      <ToggleDropdownButton
        ref={dropdownRef}
        variant="ghost"
        className="ml-auto md:relative shrink-0"
        dropdownContainerProps={{
          ['aria-controls']: 'filter-menu',
          ['aria-expanded']: opened
        }}
        onClick={() => setOpened((opened) => !opened)}
        currentOption={
          <div className="flex items-center gap-1 ">
            {!expandedSegment && (
              <>
                <MagnifyingGlassIcon className="block h-4 w-4" />
                Filter
              </>
            )}
            {!!expandedSegment && (
              <>
                <AdjustmentsHorizontalIcon className="block h-4 w-4" />
                Edit segment
              </>
            )}
            {/* <span className="block ml-1">{expandedSegment ? 'Segment' : 'Filter'}</span> */}
          </div>
        }
      >
        {opened && (
          <DropdownMenuWrapper
            id="filter-menu"
            className="md:left-auto md:w-80"
          >
            {!!expandedSegment && (
              <SegmentActionsList
                segment={expandedSegment}
                openDeleteModal={() => {
                  setModal('delete')
                  setOpened(false)
                }}
                // cancelEditing={}
                openUpdateModal={() => {
                  setModal('update')
                  setOpened(false)
                }}
                openSaveAsNewModal={() => {
                  setModal('create')
                  setOpened(false)
                }}
              />
            )}
            {!expandedSegment && (
              <SegmentsList
                closeList={() => setOpened(false)}
                openSaveModal={() => {
                  setModal('create')
                  setOpened(false)
                }}
              />
            )}
            <FilterGroup closeList={() => setOpened(false)} />
          </DropdownMenuWrapper>
        )}
      </ToggleDropdownButton>
    </>
  )
}

export const FilterGroup = ({ closeList }: { closeList: () => void }) => {
  const site = useSiteContext()
  const columns = useMemo(() => getFilterListItems(site), [site])

  return (
    <DropdownLinkGroup className="flex flex-row">
      {columns.map((filterGroups, index) => (
        <div key={index} className="flex flex-col w-1/2">
          {filterGroups.map(({ title, modals }) => (
            <div key={title}>
              <DropdownSubtitle className="pb-1">{title}</DropdownSubtitle>
              {modals
                .filter((m) => !!m)
                .map((modalKey) => (
                  <DropdownNavigationLink
                    className="text-xs"
                    onLinkClick={closeList}
                    active={false}
                    key={modalKey}
                    path={filterRoute.path}
                    params={{ field: modalKey }}
                    search={(search) => search}
                  >
                    {formatFilterGroup(modalKey)}
                  </DropdownNavigationLink>
                ))}
            </div>
          ))}
        </div>
      ))}
    </DropdownLinkGroup>
  )
}
