controllerVersion("004-002-001-002")
healthRule(:Healthrule1) do
  name("Business Transaction response time is much higher than normal")
  description("Average Response Time (ms) is > 2 : 3 standard deviation of the default baseline and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes")
  criticalExecutionCriteria do
    entityAggregationScope do
      type("AGGREGATE")
      value("0")
    end
    policyCondition do
      type("boolean")
      operator("AND")
      condition1 do
        type("leaf")
        displayName("Average Response Time (ms) Baseline Condition")
        conditionValueType("BASELINE_STANDARD_DEVIATION")
        conditionValue("3.0")
        operator("GREATER_THAN")
        conditionExpression("")
        useActiveBaseline("true")
        triggerOnNoData("false")
        metricExpression do
          type("leaf")
          functionType("VALUE")
          value("0")
          isLiteralExpression("false")
          displayName("null")
          metricDefinition do
            type("LOGICAL_METRIC")
            logicalMetricName("Average Response Time (ms)")
          end
        end
      end
      condition2 do
        type("leaf")
        displayName("Calls per Minute Condition")
        conditionValueType("ABSOLUTE")
        conditionValue("50.0")
        operator("GREATER_THAN")
        conditionExpression("")
        useActiveBaseline("false")
        triggerOnNoData("false")
        metricExpression do
          type("leaf")
          functionType("VALUE")
          value("0")
          isLiteralExpression("false")
          displayName("null")
          metricDefinition do
            type("LOGICAL_METRIC")
            logicalMetricName("Calls per Minute")
          end
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type("AGGREGATE")
      value("0")
    end
    policyCondition do
      type("boolean")
      operator("AND")
      condition1 do
        type("leaf")
        displayName("Average Response Time (ms) Baseline Condition")
        conditionValueType("BASELINE_STANDARD_DEVIATION")
        conditionValue("2.0")
        operator("GREATER_THAN")
        conditionExpression("")
        useActiveBaseline("true")
        triggerOnNoData("false")
        metricExpression do
          type("leaf")
          functionType("VALUE")
          value("0")
          isLiteralExpression("false")
          displayName("null")
          metricDefinition do
            type("LOGICAL_METRIC")
            logicalMetricName("Average Response Time (ms)")
          end
        end
      end
      condition2 do
        type("leaf")
        displayName("Calls per Minute Condition")
        conditionValueType("ABSOLUTE")
        conditionValue("100.0")
        operator("GREATER_THAN")
        conditionExpression("")
        useActiveBaseline("false")
        triggerOnNoData("false")
        metricExpression do
          type("leaf")
          functionType("VALUE")
          value("0")
          isLiteralExpression("false")
          displayName("null")
          metricDefinition do
            type("LOGICAL_METRIC")
            logicalMetricName("Calls per Minute")
          end
        end
      end
    end
  end
end
healthRule(:Healthrule1) do
  name("Business Transaction error rate is much higher than normal")
  description("Errors per Minute is > 2 : 3 standard deviation of the default baseline and Errors per Minute is > 10 per minute and CALLS_PER_MINUTE is > 50 per minute for the last 30 minutes")
  criticalExecutionCriteria do
    entityAggregationScope do
      type("AGGREGATE")
      value("0")
    end
    policyCondition do
      type("boolean")
      operator("AND")
      condition1 do
        type("leaf")
        displayName("Errors per Minute Baseline Condition")
        conditionValueType("BASELINE_STANDARD_DEVIATION")
        conditionValue("3.0")
        operator("GREATER_THAN")
        conditionExpression("")
        useActiveBaseline("true")
        triggerOnNoData("false")
        metricExpression do
          type("leaf")
          functionType("VALUE")
          value("0")
          isLiteralExpression("false")
          displayName("null")
          metricDefinition do
            type("LOGICAL_METRIC")
            logicalMetricName("Errors per Minute")
          end
        end
      end
      condition2 do
        type("boolean")
        operator("AND")
        condition1 do
          type("leaf")
          displayName("Errors per Minute Condition")
          conditionValueType("ABSOLUTE")
          conditionValue("10.0")
          operator("GREATER_THAN")
          conditionExpression("")
          useActiveBaseline("false")
          triggerOnNoData("false")
          metricExpression do
            type("leaf")
            functionType("SUM")
            value("0")
            isLiteralExpression("false")
            displayName("null")
            metricDefinition do
              type("LOGICAL_METRIC")
              logicalMetricName("Errors per Minute")
            end
          end
        end
        condition2 do
          type("leaf")
          displayName("Calls per Minute Condition")
          conditionValueType("ABSOLUTE")
          conditionValue("50.0")
          operator("GREATER_THAN")
          conditionExpression("")
          useActiveBaseline("false")
          triggerOnNoData("false")
          metricExpression do
            type("leaf")
            functionType("VALUE")
            value("0")
            isLiteralExpression("false")
            displayName("null")
            metricDefinition do
              type("LOGICAL_METRIC")
              logicalMetricName("Calls per Minute")
            end
          end
        end
      end
    end
  end
  warningExecutionCriteria do
    entityAggregationScope do
      type("AGGREGATE")
      value("0")
    end
    policyCondition do
      type("boolean")
      operator("AND")
      condition1 do
        type("leaf")
        displayName("Errors per Minute Baseline Condition")
        conditionValueType("BASELINE_STANDARD_DEVIATION")
        conditionValue("2.0")
        operator("GREATER_THAN")
        conditionExpression("")
        useActiveBaseline("true")
        triggerOnNoData("false")
        metricExpression do
          type("leaf")
          functionType("VALUE")
          value("0")
          isLiteralExpression("false")
          displayName("null")
          metricDefinition do
            type("LOGICAL_METRIC")
            logicalMetricName("Errors per Minute")
          end
        end
      end
      condition2 do
        type("boolean")
        operator("AND")
        condition1 do
          type("leaf")
          displayName("Errors per Minute Condition")
          conditionValueType("ABSOLUTE")
          conditionValue("5.0")
          operator("GREATER_THAN")
          conditionExpression("")
          useActiveBaseline("false")
          triggerOnNoData("false")
          metricExpression do
            type("leaf")
            functionType("SUM")
            value("0")
            isLiteralExpression("false")
            displayName("null")
            metricDefinition do
              type("LOGICAL_METRIC")
              logicalMetricName("Errors per Minute")
            end
          end
        end
        condition2 do
          type("leaf")
          displayName("Calls per Minute Condition")
          conditionValueType("ABSOLUTE")
          conditionValue("50.0")
          operator("GREATER_THAN")
          conditionExpression("")
          useActiveBaseline("false")
          triggerOnNoData("false")
          metricExpression do
            type("leaf")
            functionType("VALUE")
            value("0")
            isLiteralExpression("false")
            displayName("null")
            metricDefinition do
              type("LOGICAL_METRIC")
              logicalMetricName("Calls per Minute")
            end
          end
        end
      end
    end
  end
end