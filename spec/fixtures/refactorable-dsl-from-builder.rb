define(:Healthrule1, :HealthRule) do
  enabled("true")
  isDefault("true")
  alwaysEnabled("true")
  durationMin("30")
  waitTimeMin("30")
end

controllerVersion('004-002-001-002')
healthRule(:Healthrule1) do
  name('Business Transaction response time is much higher than normal')
  type('BUSINESS_TRANSACTION')
  description('Average Response Time (ms) is > 2 : 3 standard deviation of the default baseline and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes')
  affectedEntitiesMatchCriteria { affectedBtMatchCriteria { type('ALL') } }
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('boolean')
      operator('AND')
      condition1 do
        type('leaf')
        displayName('Average Response Time (ms) Baseline Condition')
        conditionValueType('BASELINE_STANDARD_DEVIATION')
        conditionValue('3.0')
        operator('GREATER_THAN')
        conditionExpression('')
        useActiveBaseline('true')
        triggerOnNoData('false')
        metricExpression do
          type('leaf')
          functionType('VALUE')
          value('0')
          isLiteralExpression('false')
          displayName('null')
          metricDefinition do
            type('LOGICAL_METRIC')
            logicalMetricName('Average Response Time (ms)')
          end
        end
      end
      condition2 do
        type('leaf')
        displayName('Calls per Minute Condition')
        conditionValueType('ABSOLUTE')
        conditionValue('50.0')
        operator('GREATER_THAN')
        conditionExpression('')
        useActiveBaseline('false')
        triggerOnNoData('false')
        metricExpression do
          type('leaf')
          functionType('VALUE')
          value('0')
          isLiteralExpression('false')
          displayName('null')
          metricDefinition do
            type('LOGICAL_METRIC')
            logicalMetricName('Calls per Minute')
          end
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('boolean')
      operator('AND')
      condition1 do
        type('leaf')
        displayName('Average Response Time (ms) Baseline Condition')
        conditionValueType('BASELINE_STANDARD_DEVIATION')
        conditionValue('2.0')
        operator('GREATER_THAN')
        conditionExpression('')
        useActiveBaseline('true')
        triggerOnNoData('false')
        metricExpression do
          type('leaf')
          functionType('VALUE')
          value('0')
          isLiteralExpression('false')
          displayName('null')
          metricDefinition do
            type('LOGICAL_METRIC')
            logicalMetricName('Average Response Time (ms)')
          end
        end
      end
      condition2 do
        type('leaf')
        displayName('Calls per Minute Condition')
        conditionValueType('ABSOLUTE')
        conditionValue('100.0')
        operator('GREATER_THAN')
        conditionExpression('')
        useActiveBaseline('false')
        triggerOnNoData('false')
        metricExpression do
          type('leaf')
          functionType('VALUE')
          value('0')
          isLiteralExpression('false')
          displayName('null')
          metricDefinition do
            type('LOGICAL_METRIC')
            logicalMetricName('Calls per Minute')
          end
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name('Business Transaction error rate is much higher than normal')
  type('BUSINESS_TRANSACTION')
  description('Errors per Minute is > 2 : 3 standard deviation of the default baseline and Errors per Minute is > 10 per minute and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes')
  affectedEntitiesMatchCriteria { affectedBtMatchCriteria { type('ALL') } }
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('boolean')
      operator('AND')
      condition1 do
        type('leaf')
        displayName('Errors per Minute Baseline Condition')
        conditionValueType('BASELINE_STANDARD_DEVIATION')
        conditionValue('3.0')
        operator('GREATER_THAN')
        conditionExpression('')
        useActiveBaseline('true')
        triggerOnNoData('false')
        metricExpression do
          type('leaf')
          functionType('VALUE')
          value('0')
          isLiteralExpression('false')
          displayName('null')
          metricDefinition do
            type('LOGICAL_METRIC')
            logicalMetricName('Errors per Minute')
          end
        end
      end
      condition2 do
        type('boolean')
        operator('AND')
        condition1 do
          type('leaf')
          displayName('Errors per Minute Condition')
          conditionValueType('ABSOLUTE')
          conditionValue('10.0')
          operator('GREATER_THAN')
          conditionExpression('')
          useActiveBaseline('false')
          triggerOnNoData('false')
          metricExpression do
            type('leaf')
            functionType('SUM')
            value('0')
            isLiteralExpression('false')
            displayName('null')
            metricDefinition do
              type('LOGICAL_METRIC')
              logicalMetricName('Errors per Minute')
            end
          end
        end
        condition2 do
          type('leaf')
          displayName('Calls per Minute Condition')
          conditionValueType('ABSOLUTE')
          conditionValue('50.0')
          operator('GREATER_THAN')
          conditionExpression('')
          useActiveBaseline('false')
          triggerOnNoData('false')
          metricExpression do
            type('leaf')
            functionType('VALUE')
            value('0')
            isLiteralExpression('false')
            displayName('null')
            metricDefinition do
              type('LOGICAL_METRIC')
              logicalMetricName('Calls per Minute')
            end
          end
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('boolean')
      operator('AND')
      condition1 do
        type('leaf')
        displayName('Errors per Minute Baseline Condition')
        conditionValueType('BASELINE_STANDARD_DEVIATION')
        conditionValue('2.0')
        operator('GREATER_THAN')
        conditionExpression('')
        useActiveBaseline('true')
        triggerOnNoData('false')
        metricExpression do
          type('leaf')
          functionType('VALUE')
          value('0')
          isLiteralExpression('false')
          displayName('null')
          metricDefinition do
            type('LOGICAL_METRIC')
            logicalMetricName('Errors per Minute')
          end
        end
      end
      condition2 do
        type('boolean')
        operator('AND')
        condition1 do
          type('leaf')
          displayName('Errors per Minute Condition')
          conditionValueType('ABSOLUTE')
          conditionValue('5.0')
          operator('GREATER_THAN')
          conditionExpression('')
          useActiveBaseline('false')
          triggerOnNoData('false')
          metricExpression do
            type('leaf')
            functionType('SUM')
            value('0')
            isLiteralExpression('false')
            displayName('null')
            metricDefinition do
              type('LOGICAL_METRIC')
              logicalMetricName('Errors per Minute')
            end
          end
        end
        condition2 do
          type('leaf')
          displayName('Calls per Minute Condition')
          conditionValueType('ABSOLUTE')
          conditionValue('50.0')
          operator('GREATER_THAN')
          conditionExpression('')
          useActiveBaseline('false')
          triggerOnNoData('false')
          metricExpression do
            type('leaf')
            functionType('VALUE')
            value('0')
            isLiteralExpression('false')
            displayName('null')
            metricDefinition do
              type('LOGICAL_METRIC')
              logicalMetricName('Calls per Minute')
            end
          end
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name('CPU utilization is too high')
  type('INFRASTRUCTURE')
  description('')
  affectedEntitiesMatchCriteria do
    affectedInfraMatchCriteria do
      type('NODES')
      nodeMatchCriteria do
        type('ANY')
        nodeMetaInfoMatchCriteria('')
        vmSysProperties('')
        envProperties('')
      end
    end
  end
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('Hardware Resources|CPU|%Busy Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('90.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('Hardware Resources|CPU|%Busy')
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('Hardware Resources|CPU|%Busy Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('75.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('Hardware Resources|CPU|%Busy')
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name('Memory utilization is too high')
  type('INFRASTRUCTURE')
  description('')
  affectedEntitiesMatchCriteria do
    affectedInfraMatchCriteria do
      type('NODES')
      nodeMatchCriteria do
        type('ANY')
        nodeMetaInfoMatchCriteria('')
        vmSysProperties('')
        envProperties('')
      end
    end
  end
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('Hardware Resources|Memory|Used % Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('90.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('Hardware Resources|Memory|Used %')
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('Hardware Resources|Memory|Used % Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('75.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('Hardware Resources|Memory|Used %')
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name('JVM Heap utilization is too high')
  type('INFRASTRUCTURE')
  description('')
  affectedEntitiesMatchCriteria do
    affectedInfraMatchCriteria do
      type('NODES')
      nodeMatchCriteria do
        type('ANY')
        nodeMetaInfoMatchCriteria('')
        vmSysProperties('')
        envProperties('')
        nodeTypes { nodeType('APP_AGENT') }
      end
    end
  end
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('JVM|Memory:Heap|Used % Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('90.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('JVM|Memory:Heap|Used %')
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('JVM|Memory:Heap|Used % Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('75.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('JVM|Memory:Heap|Used %')
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name('JVM Garbage Collection Time is too high')
  type('INFRASTRUCTURE')
  description('')
  affectedEntitiesMatchCriteria do
    affectedInfraMatchCriteria do
      type('NODES')
      nodeMatchCriteria do
        type('ANY')
        nodeMetaInfoMatchCriteria('')
        vmSysProperties('')
        envProperties('')
        nodeTypes { nodeType('APP_AGENT') }
      end
    end
  end
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('JVM|Garbage Collection|GC Time Spent Per Min (ms) Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('45000.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('JVM|Garbage Collection|GC Time Spent Per Min (ms)')
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('JVM|Garbage Collection|GC Time Spent Per Min (ms) Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('30000.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('JVM|Garbage Collection|GC Time Spent Per Min (ms)')
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name('CLR Garbage Collection Time is too high')
  type('INFRASTRUCTURE')
  description('')
  affectedEntitiesMatchCriteria do
    affectedInfraMatchCriteria do
      type('NODES')
      nodeMatchCriteria do
        type('ANY')
        nodeMetaInfoMatchCriteria('')
        vmSysProperties('')
        envProperties('')
        nodeTypes { nodeType('DOT_NET_APP_AGENT') }
      end
    end
  end
  criticalExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('CLR|Garbage Collection|GC Time Spent (%) Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('75.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('CLR|Garbage Collection|GC Time Spent (%)')
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type('AGGREGATE')
      value('0')
    end
    policyCondition do
      type('leaf')
      operator('GREATER_THAN')
      displayName('CLR|Garbage Collection|GC Time Spent (%) Condition')
      conditionValueType('ABSOLUTE')
      conditionValue('50.0')
      conditionExpression('')
      useActiveBaseline('false')
      triggerOnNoData('false')
      metricExpression do
        type('leaf')
        functionType('VALUE')
        value('0')
        isLiteralExpression('false')
        displayName('null')
        metricDefinition do
          type('LOGICAL_METRIC')
          logicalMetricName('CLR|Garbage Collection|GC Time Spent (%)')
        end
      end
    end
  end
end