#!/bin/bash
# shellcheck disable=SC2086

for node_name in "producer" "relay1" "relay2"
do
	echo "./cnode-helper-scripts/prereqs.sh -s -n testnet -t cnode_${node_name} -a alpha -f"
	./cnode-helper-scripts/prereqs.sh -s -n testnet -t cnode_${node_name} -a alpha -f
done;
