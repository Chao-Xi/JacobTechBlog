import os
from contextlib2 import contextmanager
import sys
import subprocess

print(15*'-'+'Enter the environment variable'+15*'-')

kube_conf = os.environ.get('KUBECONFIG')

if kube_conf == None:
    print('KUBECONFIG does not exist, need to be export manually')
    exit()
else:
    print(f'Current KUBECONFIG is {kube_conf}, change it if its not right')

print(15*'-'+' Run the k8s-okta-auth.sh '+15*'-')


clustername_dict = {'None':'cluster01-us-east-1.animal.bbsaas.io',
                    'US-EAST-1-Development':'cluster01-us-east-1.elmo.bbsaas.io', 
                    'US-EAST-1-Playground':'cluster01-us-east-1.fozzie.bbsaas.io', 
                   }

for key, value in clustername_dict.items():
    print("Learn Saas Fleets: "+key+" ", "Cluster Name: "+value)

cwd = os.getcwd() 
print(f'Current directory is {cwd}')


print(15*'-'+'Change directory to /Users/jxi/.kube:'+15*'-')

filename = 'okta-username' 

@contextmanager
def change_dir(destination):
    try:
        cwd = os.getcwd()
        os.chdir(destination)
        yield
    finally:
        os.chdir(cwd)

with change_dir("/Users/jxi/.kube"):
    if os.path.exists('okta-username'):
        print('okta-username Already exists')
    else: 
        print('okta-username doesnt exist, create a new one')
        with open('okta-username', 'w') as f:
            f.write('jacob.xi@blackboard.com')


with change_dir("/Users/jxi/.kube"):
    if os.path.exists('okta-id-token'):
        print('okta-id-token Already exists, need to be deleted')
        os.remove('okta-id-token')
    else:
        print('A new kta-id-token doesnt exist, create a new one')

print(15*'-'+'Export the environment variable'+15*'-')

# input_cluster_name = input("Input the cluster name you wanna enter:") 
# os.environ['KUBECONFIG'] = f"/Users/jxi/.kube/{input_cluster_name}"

if os.environ['KUBECONFIG'] != '':
    subprocess.call("./k8s-okta-auth.sh", shell=True)
else:
    exit()

# cluster_name = os.environ["KUBECONFIG"].split('/')[4]


# print(f'You enter the: {cluster_name}', '\nTest the cluster with "kubectl get ns"')

print( '\nTest the cluster with "kubectl get ns"')
