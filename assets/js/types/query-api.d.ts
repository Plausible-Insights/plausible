/* eslint-disable */
/**
 * This file was automatically generated by json-schema-to-typescript.
 * DO NOT MODIFY IT BY HAND. Instead, modify the source JSONSchema file,
 * and run json-schema-to-typescript to regenerate this file.
 */

export type Metric =
  | "visitors"
  | "visits"
  | "pageviews"
  | "views_per_visit"
  | "bounce_rate"
  | "visit_duration"
  | "events"
  | "percentage"
  | "conversion_rate"
  | "group_conversion_rate"
  | "time_on_page"
  | "total_revenue"
  | "average_revenue";
export type DateRangeShorthand = "30m" | "realtime" | "all" | "day" | "7d" | "30d" | "month" | "6mo" | "12mo" | "year";
/**
 * @minItems 2
 * @maxItems 2
 */
export type DateTimeRange = [string, string];
/**
 * @minItems 2
 * @maxItems 2
 */
export type DateRange = [string, string];
export type Dimensions = SimpleFilterDimensions | CustomPropertyFilterDimensions | GoalDimension | TimeDimensions;
export type SimpleFilterDimensions =
  | "event:name"
  | "event:page"
  | "event:hostname"
  | "visit:source"
  | "visit:channel"
  | "visit:referrer"
  | "visit:utm_medium"
  | "visit:utm_source"
  | "visit:utm_campaign"
  | "visit:utm_content"
  | "visit:utm_term"
  | "visit:screen"
  | "visit:device"
  | "visit:browser"
  | "visit:browser_version"
  | "visit:os"
  | "visit:os_version"
  | "visit:country"
  | "visit:region"
  | "visit:city"
  | "visit:country_name"
  | "visit:region_name"
  | "visit:city_name"
  | "visit:entry_page"
  | "visit:exit_page"
  | "visit:entry_page_hostname"
  | "visit:exit_page_hostname";
export type CustomPropertyFilterDimensions = string;
export type GoalDimension = "event:goal";
export type TimeDimensions = "time" | "time:month" | "time:week" | "time:day" | "time:hour";
export type FilterTree = FilterEntry | FilterAndOr | FilterNot;
export type FilterEntry = FilterWithoutGoals | FilterWithGoals;
/**
 * @minItems 3
 * @maxItems 3
 */
export type FilterWithoutGoals = [
  FilterOperationWithoutGoals | ("matches_wildcard" | "matches_wildcard_not"),
  SimpleFilterDimensions | CustomPropertyFilterDimensions,
  Clauses
];
/**
 * filter operation
 */
export type FilterOperationWithoutGoals = "is_not" | "contains_not" | "matches" | "matches_not";
export type Clauses = (string | number)[];
/**
 * @minItems 3
 * @maxItems 3
 */
export type FilterWithGoals = [
  FilterOperationWithGoals,
  GoalDimension | SimpleFilterDimensions | CustomPropertyFilterDimensions,
  Clauses
];
/**
 * filter operation
 */
export type FilterOperationWithGoals = "is" | "contains";
/**
 * @minItems 2
 * @maxItems 2
 */
export type FilterAndOr = ["and" | "or", [FilterTree, ...FilterTree[]]];
/**
 * @minItems 2
 * @maxItems 2
 */
export type FilterNot = ["not", FilterTree];
/**
 * @minItems 2
 * @maxItems 2
 */
export type OrderByEntry = [
  Metric | SimpleFilterDimensions | CustomPropertyFilterDimensions | TimeDimensions,
  "asc" | "desc"
];

export interface QueryApiSchema {
  /**
   * Domain of site to query
   */
  site_id: string;
  /**
   * List of metrics to query
   *
   * @minItems 1
   */
  metrics: [Metric, ...Metric[]];
  date?: string;
  /**
   * Date range to query
   */
  date_range: DateRangeShorthand | DateTimeRange | DateRange;
  /**
   * What to group the results by. Same as `property` in Plausible API v1
   */
  dimensions?: Dimensions[];
  /**
   * How to drill into your data
   */
  filters?: FilterTree[];
  /**
   * How to order query results
   */
  order_by?: OrderByEntry[];
  include?: {
    time_labels?: boolean;
    imports?: boolean;
    /**
     * If set, returns the total number of result rows rows before pagination under `meta.total_rows`
     */
    total_rows?: boolean;
    comparisons?:
      | {
          mode: "previous_period" | "year_over_year";
          /**
           * If set and using time:day dimensions, day-of-week of comparison query is matched
           */
          match_day_of_week?: boolean;
        }
      | {
          mode: "custom";
          /**
           * If set and using time:day dimensions, day-of-week of comparison query is matched
           */
          match_day_of_week?: boolean;
          /**
           * If custom period. A list of two ISO8601 dates or timestamps to compare against.
           *
           * @minItems 2
           * @maxItems 2
           */
          date_range: [string, string];
        };
  };
  pagination?: {
    /**
     * Number of rows to limit result to.
     */
    limit?: number;
    /**
     * Pagination offset.
     */
    offset?: number;
  };
}
