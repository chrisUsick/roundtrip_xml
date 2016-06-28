define :BaseHealthrule, :HealthRule do
  enabled 'true'
  isDefault 'true'
  alwaysEnabled 'true'
  durationMin '30'
  waitTimeMin '30'
end

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

define :BTSingleTier, :AffectedEntitiesMatchCriteria, :tier do
  affectedBtMatchCriteria do
    type 'BTS_OF_SPFICIC_TIERS'
    applicationComponents { applicationComponent tier }
  end
end

# define :NodeSingleTier, :AffectedEntitiesMatchCriteria, :tier, :node_type do
#   affectedInfraMatchCriteria do
#     type 'NODES'
#     nodeMatchCriteria do
#       type 'NODES_OF_SPECIFC_TIERS'
#       nodeMetaInfoMatchCriteria ""
#       vmSysProperties ""
#       envProperties ""
#       nodeTypes { nodeType node_type }
#     end
#     components { applicationComponent tier }
#   end
# end

