import React from 'react';

import Datepicker from './datepicker'
import SiteSwitcher from './site-switcher'
import Filters from './filters'
import CurrentVisitors from './stats/current-visitors'
import VisitorGraph from './stats/visitor-graph'
import Sources from './stats/sources'
import Pages from './stats/pages'
import Countries from './stats/countries'
import Devices from './stats/devices'
import Conversions from './stats/conversions'
import { withPinnedHeader } from './pinned-header-hoc';

class Historical extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      refresh: 0
    }
  }

  renderConversions() {
    if (this.props.site.hasGoals) {
      return (
        <div className="w-full block md:flex items-start justify-between mt-6">
          <Conversions site={this.props.site} query={this.props.query} refresh={this.state.refresh} />
        </div>
      )
    }
  }

  render() {
    const {pinned, stuck, togglePinned} = this.props;
    const { refresh } = this.state;

    return (
      <div className="mb-12">
        <div id="stats-container-top"></div>
        <div className={`${pinned ? 'sticky top-0 bg-gray-50 dark:bg-gray-850 pt-4 pb-2 z-9' : 'pt-4 pb-2'} ${pinned && stuck ? 'z-10 fullwidth-shadow' : ''}`}>
          <div className="w-full sm:flex justify-between items-center">
            <div className="w-full flex items-center">
              <SiteSwitcher site={this.props.site} loggedIn={this.props.loggedIn} />
              <CurrentVisitors timer={this.props.timer} site={this.props.site} refresh={refresh}/>
            </div>
            <div className='dark:text-gray-100 flex items-center justify-end'>
              <Datepicker site={this.props.site} query={this.props.query} refresh={() => this.setState((state) => ({refresh: state.refresh + 1}))}/>
              <span title={pinned ? 'Prevent this menu from remaining on the screen as you scroll' : 'Allow this menu to remain on the screen as you scroll'}>
                <svg
                  style={{cursor: 'pointer', transform: `rotate(-${pinned ? 135 : 45}deg)`}}
                  onClick={togglePinned}
                  height='18px'
                  width='18px'
                  fill={pinned ? 'currentColor' : 'transparent'}
                  stroke="currentColor"
                  viewBox="0 0 100 100"
                  >
                  <path strokeWidth="8" d="M52.11,91.29c-0.48,0.48-1.26,0.48-1.74,0L31.28,72.19L9.27,94.21c-0.17,0.17-0.39,0.29-0.63,0.34l-2.17,0.43  c-0.86,0.17-1.62-0.59-1.44-1.44l0.43-2.17c0.05-0.24,0.16-0.46,0.34-0.63l22.01-22.01L8.71,49.62c-0.48-0.48-0.48-1.26,0-1.74  c4.11-4.11,10.39-4.68,15.12-1.76l35.03-27.74c-1.66-4.38-0.73-9.51,2.79-13.03c0.48-0.48,1.26-0.48,1.74,0l31.25,31.25  c0.48,0.48,0.48,1.26,0,1.74c-3.52,3.52-8.65,4.45-13.03,2.79L53.87,76.16C56.79,80.9,56.22,87.18,52.11,91.29z" />
                </svg>
              </span>
            </div>
          </div>
          <Filters query={this.props.query} history={this.props.history} />
        </div>
        <VisitorGraph site={this.props.site} query={this.props.query} refresh={refresh} />
        <div className="w-full block md:flex items-start justify-between">
          <Sources site={this.props.site} query={this.props.query} refresh={refresh} />
          <Pages site={this.props.site} query={this.props.query} refresh={refresh} />
        </div>
        <div className="w-full block md:flex items-start justify-between">
          <Countries site={this.props.site} query={this.props.query} refresh={refresh} />
          <Devices site={this.props.site} query={this.props.query} refresh={refresh} />
        </div>
        { this.renderConversions() }
      </div>
    )
  }
}

export default withPinnedHeader(Historical, 'historical');
