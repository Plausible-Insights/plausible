/** @format */

import React, { ChangeEventHandler, useCallback, useState, useRef } from 'react'
import { isModifierPressed, useKeybind } from '../keybinding'
import { useDebounce } from '../custom-hooks'
import classNames from 'classnames'

export const SearchInput = ({
  className,
  onSearch,
  initialValue,
  placeholderFocused,
  placeholderUnfocused
}: {
  className?: string
  onSearch: (value: string) => void
  initialValue?: string
  placeholderFocused?: string
  placeholderUnfocused?: string
}) => {
  const searchBoxRef = useRef<HTMLInputElement>(null)
  const [isFocused, setIsFocused] = useState(false)

  const onSearchInputChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      onSearch(event.target.value)
    },
    [onSearch]
  )
  const debouncedOnSearchInputChange = useDebounce(onSearchInputChange)

  const blurSearchBox = useCallback(
    (event: KeyboardEvent) => {
      if (isFocused) {
        searchBoxRef.current?.blur()
        event.stopPropagation()
      }
    },
    [isFocused]
  )

  const focusSearchBox = useCallback(
    (event: KeyboardEvent) => {
      if (!isFocused) {
        searchBoxRef.current?.focus()
        event.stopPropagation()
      }
    },
    [isFocused]
  )

  useKeybind({
    target: document,
    keyboardKey: 'Escape',
    type: 'keyup',
    handler: blurSearchBox,
    shouldIgnoreWhen: [isModifierPressed]
  })

  useKeybind({
    target: document,
    keyboardKey: '/',
    type: 'keyup',
    handler: focusSearchBox,
    shouldIgnoreWhen: [isModifierPressed]
  })

  return (
    <>
      <input
        onBlur={() => setIsFocused(false)}
        onFocus={() => setIsFocused(true)}
        ref={searchBoxRef}
        type="text"
        placeholder={
          isFocused
            ? (placeholderFocused ?? 'Search')
            : (placeholderUnfocused ?? 'Press / to search')
        }
        value={initialValue}
        className={classNames(
          'shadow-sm dark:bg-gray-900 dark:text-gray-100 focus:ring-indigo-500 focus:border-indigo-500 block sm:text-sm border-gray-300 dark:border-gray-500 rounded-md dark:bg-gray-800 w-48',
          className
        )}
        onChange={debouncedOnSearchInputChange}
      />
    </>
  )
}
