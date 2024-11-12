#!/bin/bash

# license 변경
#kubectl exec -it goldilocks2-0 -n goldilocks -- /bin/bash << EOF
#cp /home/sunje/goldilocks_data/goldilocks/goldilocks2-0/conf/license /home/sunje/goldilocks_home/license/
#EOF


# cluster ip 조회
G1N1=`kubectl get pod goldilocks-0 -n goldilocks -o custom-columns=IP:.status.podIP --no-headers`
G1N2=`kubectl get pod goldilocks2-0 -n goldilocks -o custom-columns=IP:.status.podIP --no-headers`

echo "alter cluster location G1N1 host '$G1N1' port 10101;"
echo $G1N2

# startup mount
kubectl exec -it goldilocks-0 -n goldilocks -- /bin/bash -c "/home/sunje/goldilocks_home/bin/gsqlnet sys gliese --as sysdba --conn-string 'host=127.0.0.1;port=22581' << EOF
startup mount;
\q
EOF"


# alter cluster location
## G1N1 정보
kubectl exec -it goldilocks-0 -n goldilocks -- /bin/bash -c "/home/sunje/goldilocks_home/bin/gsqlnet sys gliese --as sysdba --conn-string 'host=127.0.0.1;port=22581' << EOF
alter cluster location G1N1 host '$G1N1' port 10101;
\q
EOF"

## G1N2 정보
kubectl exec -it goldilocks-0 -n goldilocks -- /bin/bash -c "/home/sunje/goldilocks_home/bin/gsqlnet sys gliese --as sysdba --conn-string 'host=127.0.0.1;port=22581' << EOF
alter cluster location G1N2 host '$G1N2' port 10101;
\q
EOF"


# local open
kubectl exec -it goldilocks-0 -n goldilocks -- /bin/bash -c "/home/sunje/goldilocks_home/bin/gsqlnet sys gliese --as sysdba --conn-string 'host=127.0.0.1;port=22581' << EOF
alter system open local database;
\q
EOF"

# join
kubectl exec -it goldilocks-0 -n goldilocks -- /bin/bash -c "/home/sunje/goldilocks_home/bin/gsqlnet sys gliese --as sysdba --conn-string 'host=127.0.0.1;port=22581' << EOF
alter system join database;
\q
EOF"