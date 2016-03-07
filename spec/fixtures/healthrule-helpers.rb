define :BasicExpression, :MetricExpression, :function, :metric_name do
  type 'leaf'
  functionType function
  value '0'
  isLiteralExpression 'false'
  displayName 'null'
  metricDefinition do
    type 'LOGICAL_METRIC'
    logicalMetricName metric_name
  end
end

define :PolicyCondition2, :PolicyCondition do
  type 'boolean'
  operator 'AND'
end

define :RegularExecutionCriteria, :WarningExecutionCriteria do
  entityAggregationScope do
    type 'AGGREGATE'
    value '0'
  end
end