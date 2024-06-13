kubectl apply -f cr.yaml -f sa.yaml -f crb.yaml
kubectl apply -f crd.yaml

cd mysql-operator-shell/ && ./build.sh && cd ..

kubectl apply -f deployment-operator-shell.yaml -f mysql.yaml
