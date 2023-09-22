#!/bin/bash
LOG_FILE='/var/log/thingsboard/thingsboard.log'

QUERY='select rule_node.name as rule_node_name, rule_chain.name as rule_chain_name, tenant.title as tenant_name from rule_node join rule_chain on rule_chain.id=rule_node.rule_chain_id join tenant on tenant.id=rule_chain.tenant_id where rule_node.id in ('
ARRAY_IDS=$(cat $LOG_FILE | grep "Failed to init actor, attempt 1" | grep -o "|.*\]" | sed 's/^.//;s/.$//' | sort -u )

for i in $ARRAY_IDS
do
    QUERY="${QUERY}'${i}', ";
done

QUERY=$(echo ${QUERY} | sed 's/.$//')

echo "${QUERY});"