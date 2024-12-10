/** @format */

import React, { useEffect, useMemo, useRef, useState } from 'react'
import {
  DropdownLinkGroup,
  DropdownMenuWrapper,
  DropdownNavigationLink,
  DropdownSubtitle,
  ToggleDropdownButton
} from '../components/dropdown'
import {
  cleanLabels,
  FILTER_MODAL_TO_FILTER_GROUP,
  formatFilterGroup,
  remapToApiFilters
} from '../util/filters'
import { PlausibleSite, useSiteContext } from '../site-context'
import { filterRoute } from '../router'
import { useOnClickOutside } from '../util/use-on-click-outside'
import { EditSegmentMenu, SegmentsList } from '../segments/segments-dropdown'
import { useQueryContext } from '../query-context'
import { useSegmentExpandedContext } from '../segments/segment-expanded-context'
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
import { PlusIcon } from '@heroicons/react/20/solid'
// import {
//   PlusIcon,
// } from '@heroicons/react/24/outline'
import { SearchInput } from '../components/search-input'
import classNames from 'classnames'
import { isModifierPressed, isTyping, Keybind } from '../keybinding'

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
  const user = useUserContext()
  const dropdownRef = useRef<HTMLDivElement>(null)
  const [opened, setOpened] = useState(false)
  const site = useSiteContext()
  const columns = useMemo(() => getFilterListItems(site), [site])
  const { query } = useQueryContext()
  const { expandedSegment, modal } = useSegmentExpandedContext()
  const queryClient = useQueryClient()
  const navigate = useAppNavigate()
  const [search, setSearch] = useState<string>()
  useEffect(() => {
    setSearch(undefined)
  }, [opened])
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
        },
        state: {
          expandedSegment: null,
          modal: null
        },
        replace: true
      })
      setOpened(false)
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
        },
        state: {
          expandedSegment: null,
          modal: null
        },
        replace: true
      })
      setOpened(false)
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
        search: (s) => {
          return {
            ...s,
            filters: null,
            labels: null
          }
        },
        state: {
          expandedSegment: null,
          modal: null
        },
        replace: true
      })
      setOpened(false)
    }
  })

  useOnClickOutside({
    ref: dropdownRef,
    active: opened && modal === null,
    handler: () => setOpened(false)
  })

  console.log(modal)

  return (
    <>
      {user.loggedIn && modal === 'update' && expandedSegment && (
        <UpdateSegmentModal
          canTogglePersonal={['admin', 'owner', 'super_admin'].includes(
            user.role
          )}
          segment={expandedSegment}
          namePlaceholder={getSegmentNamePlaceholder(query)}
          onClose={() =>
            navigate({
              search: (s) => s,
              state: { expandedSegment, modal: null },
              replace: true
            })
          }
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
          onClose={() =>
            navigate({
              search: (s) => s,
              state: { expandedSegment, modal: null },
              replace: true
            })
          }
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
          onClose={() =>
            navigate({
              search: (s) => s,
              state: { expandedSegment, modal: null },
              replace: true
            })
          }
          onSave={({ id }) => deleteSegment.mutate({ id })}
        />
      )}
      <div className="ml-auto shrink-0 flex gap-x-2">
        <ToggleDropdownButton
          ref={dropdownRef}
          variant="ghost"
          className="ml-auto md:relative"
          dropdownContainerProps={{
            ['aria-controls']: 'filter-menu',
            ['aria-expanded']: opened
          }}
          onClick={() => setOpened((opened) => !opened)}
          currentOption={
            <div className="flex items-center gap-1 ">
              <PlusIcon className="block h-4 w-4" />
              Add filter
            </div>
          }
        >
          {opened && (
            <DropdownMenuWrapper
              id="filter-menu"
              className="md:left-auto md:w-80"
            >
              <Keybind
                keyboardKey="Escape"
                shouldIgnoreWhen={[isModifierPressed, isTyping]}
                type="keyup"
                handler={(event) => {
                  event.stopPropagation()
                  setOpened(false)
                }}
                target={dropdownRef.current}
              />

              <DropdownLinkGroup className="flex flex-row">
                {columns.map((filterGroups, index) => (
                  <div key={index} className="flex flex-col w-1/2">
                    {filterGroups.map(({ title, modals }) => (
                      <div key={title}>
                        <DropdownSubtitle className="pb-1">
                          {title}
                        </DropdownSubtitle>
                        {modals
                          .filter((m) => !!m)
                          .map((modalKey) => (
                            <DropdownNavigationLink
                              className={classNames('text-xs', {
                                'opacity-50':
                                  search?.trim().length &&
                                  !title
                                    .toLowerCase()
                                    .includes(search.trim().toLowerCase()) &&
                                  !formatFilterGroup(modalKey)
                                    .toLowerCase()
                                    .includes(search.trim().toLowerCase())
                              })}
                              onLinkClick={() => setOpened(false)}
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
              {!expandedSegment && (
                <SegmentsList
                  closeList={() => setOpened(false)}
                  searchValue={search}
                />
              )}
            </DropdownMenuWrapper>
          )}
        </ToggleDropdownButton>

        {!!expandedSegment && <EditSegmentMenu />}
      </div>
    </>
  )
}
