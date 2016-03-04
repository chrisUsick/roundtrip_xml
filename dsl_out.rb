controllerVersion '004-001-008-007'
healthRule do
  name 'Business Transaction response time is much higher than normal'
  type 'BUSINESS_TRANSACTION'
  description 'Average Response Time (ms) is > 2 : 3 standard deviation of the default baseline and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes'
  enabled 'true'
  isDefault 'true'
  alwaysEnabled 'true'
  durationMin '30'
  waitTimeMin '30'
  affectedEntitiesMatchCriteria do
    affectedBtMatchCriteria do
      type 'ALL'
    end
  end
  criticalExecutionCriteria do
    entityAggregationScope do
      type 'AGGREGATE'
      value '0'
    end
    policyCondition do
      type 'boolean'
      operator 'AND'
      condition1 do
        type 'leaf'
        displayName 'Average Response Time (ms) Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue '3.0'
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Average Response Time (ms)'
          end
        end
      end
      condition2 do
        type 'leaf'
        displayName 'Calls per Minute Condition'
        conditionValueType 'ABSOLUTE'
        conditionValue '50.0'
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'false'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Calls per Minute'
          end
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type 'AGGREGATE'
      value '0'
    end
    policyCondition do
      type 'boolean'
      operator 'AND'
      condition1 do
        type 'leaf'
        displayName 'Average Response Time (ms) Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue '2.0'
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Average Response Time (ms)'
          end
        end
      end
      condition2 do
        type 'leaf'
        displayName 'Calls per Minute Condition'
        conditionValueType 'ABSOLUTE'
        conditionValue '100.0'
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'false'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Calls per Minute'
          end
        end
      end
    end
  end
end
