define :BaseHealthrule, :HealthRule do
  enabled "true"
  isDefault "true"
  alwaysEnabled "true"
  durationMin "30"
  waitTimeMin "30"
end

define :SinglePolicyHealthrule, :BaseHealthrule,
       :logical_metric,
       :crit_value, :warn_value do
  criticalExecutionCriteria do
    entityAggregationScope do
      type 'AGGREGATE'
      value '0'
    end
    policyCondition do
      type 'leaf'
      operator 'GREATER_THAN'
      displayName "#{logical_metric} Condition"
      conditionValueType 'ABSOLUTE'
      conditionValue crit_value
      conditionExpression ''
      useActiveBaseline 'false'
      triggerOnNoData 'false'
      metricExpression do
        type 'leaf'
        functionType 'VALUE'
        value '0'
        isLiteralExpression 'false'
        displayName 'null'
        metricDefinition do
          type 'LOGICAL_METRIC'
          logicalMetricName logical_metric
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
      type 'leaf'
      operator 'GREATER_THAN'
      displayName "#{logical_metric} Condition"
      conditionValueType 'ABSOLUTE'
      conditionValue warn_value
      conditionExpression ''
      useActiveBaseline 'false'
      triggerOnNoData 'false'
      metricExpression do
        type 'leaf'
        functionType 'VALUE'
        value '0'
        isLiteralExpression 'false'
        displayName 'null'
        metricDefinition do
          type 'LOGICAL_METRIC'
          logicalMetricName logical_metric
        end
      end
    end
  end
end

define :AllNodesMatch, :AffectedEntitiesMatchCriteria do
  affectedInfraMatchCriteria do
    type 'NODES'
    nodeMatchCriteria do
      type 'ANY'
      nodeMetaInfoMatchCriteria ''
      vmSysProperties ''
      envProperties ''
    end
  end
end


define :BTResponseTime, :BaseHealthrule,
       :crit_standard_dev, :crit_calls_per_minute,
       :warn_standard_dev, :warn_calls_per_minute do
  name 'Business Transaction response time is much higher than normal'
  type 'BUSINESS_TRANSACTION'
  description 'Average Response Time  ms is > 2 : 3 standard deviation of the default baseline and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes'
  affectedEntitiesMatchCriteria { affectedBtMatchCriteria { type 'ALL' } }
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
        displayName 'Average Response Time  ms Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue crit_standard_dev
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        triggerOnNoData 'false'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Average Response Time  ms'
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
        triggerOnNoData 'false'
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
        displayName 'Average Response Time  ms Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue warn_standard_dev
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        triggerOnNoData 'false'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Average Response Time  ms'
          end
        end
      end
      condition2 do
        type 'leaf'
        displayName 'Calls per Minute Condition'
        conditionValueType 'ABSOLUTE'
        conditionValue warn_calls_per_minute
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'false'
        triggerOnNoData 'false'
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

define :BTErrorRate, :BaseHealthrule,
       :crit_standard_dev, :crit_errors_per_minute,
       :warn_standard_dev, :warn_errors_per_minute do
  name 'Business Transaction error rate is much higher than normal'
  type 'BUSINESS_TRANSACTION'
  description 'Errors per Minute is > 2 : 3 standard deviation of the default baseline and Errors per Minute is > 10 per minute and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes'
  affectedEntitiesMatchCriteria { affectedBtMatchCriteria { type 'ALL' } }
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
        displayName 'Errors per Minute Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue crit_standard_dev
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        triggerOnNoData 'false'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Errors per Minute'
          end
        end
      end
      condition2 do
        type 'boolean'
        operator 'AND'
        condition1 do
          type 'leaf'
          displayName 'Errors per Minute Condition'
          conditionValueType 'ABSOLUTE'
          conditionValue crit_errors_per_minute
          operator 'GREATER_THAN'
          conditionExpression ''
          useActiveBaseline 'false'
          triggerOnNoData 'false'
          metricExpression do
            type 'leaf'
            functionType 'SUM'
            value '0'
            isLiteralExpression 'false'
            displayName 'null'
            metricDefinition do
              type 'LOGICAL_METRIC'
              logicalMetricName 'Errors per Minute'
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
          triggerOnNoData 'false'
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
        displayName 'Errors per Minute Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue warn_standard_dev
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        triggerOnNoData 'false'
        metricExpression do
          type 'leaf'
          functionType 'VALUE'
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName 'Errors per Minute'
          end
        end
      end
      condition2 do
        type 'boolean'
        operator 'AND'
        condition1 do
          type 'leaf'
          displayName 'Errors per Minute Condition'
          conditionValueType 'ABSOLUTE'
          conditionValue warn_errors_per_minute
          operator 'GREATER_THAN'
          conditionExpression ''
          useActiveBaseline 'false'
          triggerOnNoData 'false'
          metricExpression do
            type 'leaf'
            functionType 'SUM'
            value '0'
            isLiteralExpression 'false'
            displayName 'null'
            metricDefinition do
              type 'LOGICAL_METRIC'
              logicalMetricName 'Errors per Minute'
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
          triggerOnNoData 'false'
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
end

define :CPUUtilization, :SinglePolicyHealthrule,
       :crit_cpu_busy, :warn_cpu_busy do
  name 'CPU utilization is too high'
  type 'INFRASTRUCTURE'
  description ''
  affectedEntitiesMatchCriteria :AllNodesMatch do

  end
  crit_value crit_cpu_busy
  warn_value warn_cpu_busy

  logical_metric 'Hardware Resources|CPU|%Busy'

end