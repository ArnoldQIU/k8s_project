NUM=$1
echo "init all node"
for v in `seq 1 $NUM`
do
	RUN="cd home/node$v && sh stop.sh && chmod 755 raft-init.sh && ./raft-init.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$RUN"
done

for v in `seq 1 $NUM`
do
	RUN="cd home/node$v && chmod 755 raft-start.sh && ./raft-start.sh"
	kubectl exec $(kubectl get pods --selector=node=node$v|  awk 'NR>1 {print $1}') -- bash -c "$RUN" &
done