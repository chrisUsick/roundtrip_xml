use_file './spec/fixtures/healthrule-helpers.rb'
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
  criticalExecutionCriteria :RegularExecutionCriteria do

    policyCondition :PolicyCondition2 do
      condition1 do
        type 'leaf'
        displayName 'Average Response Time (ms) Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue '3.0'
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        metricExpression :BasicExpression do
          function 'VALUE'
          metric_name 'Average Response Time (ms)'
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
        metricExpression :BasicExpression do
          function'VALUE'
          metric_name 'Calls per Minute'
        end
      end
    end
  end
  warningExecutionCriteria :RegularExecutionCriteria do
    policyCondition :PolicyCondition2 do
      condition1 do
        type 'leaf'
        displayName 'Average Response Time (ms) Baseline Condition'
        conditionValueType 'BASELINE_STANDARD_DEVIATION'
        conditionValue '2.0'
        operator 'GREATER_THAN'
        conditionExpression ''
        useActiveBaseline 'true'
        metricExpression :BasicExpression do
          function 'VALUE'
          metric_name 'Average Response Time (ms)'
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
        metricExpression :BasicExpression do
          function 'VALUE'
          metric_name 'Calls per Minute'
        end
      end
    end
  end
end
