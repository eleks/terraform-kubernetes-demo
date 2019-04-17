#!/bin/bash

CMD=$1
TGT=$2

if [ "$CMD" = "bash" ]; then
	kubectl exec $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $TGT) -it bash
elif [ "$CMD" = "tail" ]; then
	kubectl logs -f $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $TGT)
elif [ "$CMD" = "logs" ]; then
	kubectl logs $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep $TGT)
else
	echo "kub <command> <target>"
	echo "-------------------------------------------------------------------------------------"
	echo "  COMMANDS:"
	echo "    bash <pod-name-part>        starts bash for the first matching pod"
	echo "    tail <pod-name-part>        starts log collection 'logs -f' for first matching pod"
	echo "    tail <pod-name-part>        shows log for specified pod"
	echo "-------------------------------------------------------------------------------------"
	echo "  EXAMPLE:"
	echo "    kub bash bpm                starts bash for the pod with name matching 'bpm'"

fi
