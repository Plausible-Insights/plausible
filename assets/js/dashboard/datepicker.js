import React from 'react';
import Transition from "../transition.js";
import { withRouter, Link } from 'react-router-dom'
import Flatpickr from "react-flatpickr";
import {shiftDays, shiftMonths, formatDay, formatDayShort, formatMonthYYYY, formatISO, isToday, lastMonth, nowForSite, isSameMonth} from './date'
import { navigateToQuery, QueryLink } from './query.js'


class DatePicker extends React.Component {
  constructor(props) {
    super(props)
    this.handleKeyup = this.handleKeyup.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.state = {mode: 'menu', open: false}
  }

  componentDidMount() {
    document.addEventListener('keyup', this.handleKeyup);
    document.addEventListener('mousedown', this.handleClick, false);
  }

  componentWillUnmount() {
    document.removeEventListener("keyup", this.handleKeyup);
    document.removeEventListener('mousedown', this.handleClick, false);
  }

  handleKeyup(e) {
    const {query, history} = this.props

    if (e.ctrlKey || e.ctrlKey || e.altKey) return

    const newSearch = {
      period: false,
      from: false,
      to: false,
      date: false
    }

    if (e.key === 'ArrowLeft') {
      if (query.period === 'day') {
        const prevDate = formatISO(shiftDays(query.date, -1))
        newSearch.period = 'day'
        newSearch.date = prevDate
      } else if (query.period === 'month') {
        const prevMonth = formatISO(shiftMonths(query.date, -1))
        newSearch.period = 'month'
        newSearch.date = prevMonth
      }
    } else if (e.key === 'ArrowRight') {
      if (query.period === 'day') {
        const nextDate = formatISO(shiftDays(query.date, 1))
        newSearch.period = 'day'
        newSearch.date = nextDate
      } else if (query.period === 'month') {
        const nextMonth = formatISO(shiftMonths(query.date, 1))
        newSearch.period = 'month'
        newSearch.date = nextMonth
      }
    }

    if (newSearch.date) {
      navigateToQuery(
        history,
        query,
        newSearch
      )
    }
  }

  handleClick(e) {
    if (this.dropDownNode && this.dropDownNode.contains(e.target)) return;

    this.setState({open: false})
  }

  timeFrameText() {
    const {query, site} = this.props

    if (query.period === 'day') {
      if (isToday(site, query.date)) {
        return 'Today'
      } else {
        return formatDay(query.date)
      }
    } else if (query.period === '7d') {
      return 'Last 7 days'
    } else if (query.period === '30d') {
      return 'Last 30 days'
    } else if (query.period === 'month') {
      return formatMonthYYYY(query.date)
    } else if (query.period === '6mo') {
      return 'Last 6 months'
    } else if (query.period === '12mo') {
      return 'Last 12 months'
    } else if (query.period === 'realtime') {
      return 'Realtime'
    } else if (query.period === 'custom') {
      return `${formatDayShort(query.from)} - ${formatDayShort(query.to)}`
    }
  }

  renderArrow(period, prevDate, nextDate) {
    return (
      <div className="flex rounded shadow bg-white dark:bg-gray-800 mr-4 cursor-pointer">
        <QueryLink to={{date: prevDate}} query={this.props.query} className="flex items-center px-2 border-r border-gray-300 dark:border-gray-500 dark:text-gray-100">
          <svg className="feather h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </QueryLink>
        <QueryLink to={{date: nextDate}} query={this.props.query} className="flex items-center px-2 dark:text-gray-100">
          <svg className="feather h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </QueryLink>
      </div>
    )
  }

  renderArrows() {
    const {query} = this.props

    if (query.period === 'month') {
      const prevDate = formatISO(shiftMonths(query.date, -1))
      const nextDate = formatISO(shiftMonths(query.date, 1))

      return this.renderArrow('month', prevDate, nextDate)
    } else if (query.period === 'day') {
      const prevDate = formatISO(shiftDays(query.date, -1))
      const nextDate = formatISO(shiftDays(query.date, 1))

      return this.renderArrow('day', prevDate, nextDate)
    }
  }

  open() {
    this.setState({mode: 'menu', open: true})
  }

  renderDropDown() {
    return (
      <div className="relative" style={{height: '35.5px', width: '190px'}}  ref={node => this.dropDownNode = node}>
        <div onClick={this.open.bind(this)} className="flex items-center justify-between rounded bg-white dark:bg-gray-800 shadow px-4 pr-3 py-2 leading-tight cursor-pointer text-sm font-medium text-gray-800 dark:text-gray-200 h-full">
          <span className="mr-2">{this.timeFrameText()}</span>
          <svg className="text-pink-500 h-4 w-4" xmlns="http://www.w3.org/2000/svg"  viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="6 9 12 15 18 9"></polyline>
          </svg>
        </div>

        <Transition
          show={this.state.open}
          enter="transition ease-out duration-100 transform"
          enterFrom="opacity-0 scale-95"
          enterTo="opacity-100 scale-100"
          leave="transition ease-in duration-75 transform"
          leaveFrom="opacity-100 scale-100"
          leaveTo="opacity-0 scale-95"
        >
          {this.renderDropDownContent()}
        </Transition>
      </div>
    )
  }

  close() {
    this.setState({open: false})
  }

  renderLink(period, text, opts = {}) {
    const {query, site} = this.props
    let boldClass;
    if (query.period === 'day' && period === 'day') {
      boldClass = isToday(site, query.date) ? 'font-bold' : ''
    } else if (query.period === 'month' && period === 'month') {
      const linkDate = opts.date || nowForSite(site)
      boldClass = isSameMonth(linkDate, query.date) ? 'font-bold' : ''
    } else {
      boldClass = query.period === period ? 'font-bold' : ''
    }

    if (opts.date) { opts.date = formatISO(opts.date) }

    return (
      <QueryLink to={{period, ...opts}} onClick={this.close.bind(this)} query={this.props.query} className={boldClass + ' block px-4 py-2 text-sm leading-tight hover:bg-gray-100 dark:hover:bg-gray-900 hover:text-gray-900 dark:hover:text-gray-100'}>
        {text}
      </QueryLink>
    )
  }

  renderDropDownContent() {
    if (this.state.mode === 'menu') {
      return (
        <div className="absolute mt-2 rounded shadow-md z-10" style={{width: '235px', right: '-14px'}}>
          <div className="rounded bg-white dark:bg-gray-800 ring-1 ring-black ring-opacity-5 font-medium text-gray-800 dark:text-gray-200">
            <div className="py-1">
              { this.renderLink('day', 'Today') }
              { this.renderLink('realtime', 'Realtime') }
            </div>
            <div className="border-t border-gray-200 dark:border-gray-500"></div>
            <div className="py-1">
              { this.renderLink('7d', 'Last 7 days') }
              { this.renderLink('30d', 'Last 30 days') }
            </div>
            <div className="border-t border-gray-200 dark:border-gray-500"></div>
            <div className="py-1">
              { this.renderLink('month', 'This month') }
              { this.renderLink('month', 'Last month', {date: lastMonth(this.props.site)}) }
            </div>
            <div className="border-t border-gray-200 dark:border-gray-500"></div>
            <div className="py-1">
              { this.renderLink('6mo', 'Last 6 months') }
              { this.renderLink('12mo', 'Last 12 months') }
            </div>
            <div className="border-t border-gray-200 dark:border-gray-500"></div>
            <div className="py-1">
              <span onClick={e => this.setState({mode: 'calendar'}, this.openCalendar.bind(this))} className="block px-4 py-2 text-sm leading-tight hover:bg-gray-100 dark:hover:bg-gray-900 hover:text-gray-900 dark:hover:text-gray-100 cursor-pointer">Custom range</span>
            </div>
          </div>
        </div>
      )
    } else if (this.state.mode === 'calendar') {
      const insertionDate = new Date(this.props.site.insertedAt);
      const dayBeforeCreation = insertionDate - 86400000;
      return <Flatpickr options={{mode: 'range', maxDate: 'today', minDate: dayBeforeCreation, showMonths: 1, static: true, animate: false}} ref={calendar => this.calendar = calendar} className="invisible" onChange={this.setCustomDate.bind(this)} />
    }
  }

  setCustomDate(dates) {
    if (dates.length === 2) {
      const [from, to] = dates
      navigateToQuery(
        this.props.history,
        this.props.query,
        {
          period: 'custom',
          date: false,
          from: formatISO(from),
          to: formatISO(to),
        }
      )
      this.close()
    }
  }

  openCalendar() {
    this.calendar && this.calendar.flatpickr.open()
  }

  render() {
    return (
      <div className="flex justify-between sm:justify-between">
        { this.renderArrows() }
        { this.renderDropDown() }
      </div>
    )
  }
}

export default withRouter(DatePicker)
