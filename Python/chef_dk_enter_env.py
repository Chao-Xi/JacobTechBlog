import os
from shutil import copyfile
import fnmatch
# print(os.getcwd()+'/.chef/')
# print(os.path.isdir(os.getcwd()))

knife_block_dict= {'play':'us-east-1 => Playground','dts':'us-east-1 => Dev,Test,Stage', 'prod':'us-east-1 => Production', 'sin':'Singapore => All',
'syd':'Sydney => All', 'frank': 'Frankfurt => All', 'cat':'us-east-cat => All'}

for key, value in knife_block_dict.items():
    print("Block:"+ key+" ", "Env: "+value)

print(15*'-'+'Chose your block:'+15*'-')

# block_var = input("Input the chef block you wanna enter:") 

# ori_knife_conf = 'knife-'+block_var+'.rb'
# client_key = 'jxi-'+block_var+'.pem'

# print(ori_knife_conf)
# print(client_key)


def enter_chef_block(ori_knife_conf, client_key):

    fileslist = []
    for dirpath, dirname, filenames in os.walk(os.getcwd()):
        fileslist.append(filenames)
    
    # ln -s ~/.chef/knife-play.rb ~/.chef/knife.rb

    if client_key or 'knife.rb' in fileslist[0]:
        
        if 'knife.rb' in fileslist[0]:
            print('knife.rb exists need delete old one and create new softlink')
            os.remove(os.getcwd()+'/knife.rb')
            os.symlink(os.getcwd()+f'/.chef/{ori_knife_conf}', os.getcwd()+'/knife.rb')
        else:
            print('knife.rb does not exist, need create new knife.rb softlink')
            os.symlink(os.getcwd()+f'/.chef/{ori_knife_conf}', os.getcwd()+'/knife.rb')
            
        
        pattern = '*.pem'
        matching = fnmatch.filter(fileslist[0], pattern)
        
    # cp jxi-play.pem ../jxi-play.pem

        if matching:
            print('old client_keys already exist, need delete and create new client key')
            for old_keys in matching:
                os.remove(os.getcwd()+f'/{old_keys}')
                copyfile(os.getcwd()+f'/.chef/{client_key}', os.getcwd()+f'/{client_key}')
        else:
            print('no client key exist')
            copyfile(os.getcwd()+f'/.chef/{client_key}', os.getcwd()+f'/{client_key}')

        # if client_key in fileslist[0]:
        #   print('old client_key already exists')  
        #   pattern = '*.pem'
        #   matching = fnmatch.filter(fileslist[0], pattern)            
        #   for old_keys in matching:
        #       os.remove(os.getcwd()+f'/{old_keys}')
        #   copyfile(os.getcwd()+f'/.chef/{client_key}', os.getcwd()+f'/{client_key}')
        # else:
        #   print('no client key exist')
        #   copyfile(os.getcwd()+f'/.chef/{client_key}', os.getcwd()+f'/{client_key}')
    else:
        os.symlink(os.getcwd()+f'/.chef/{ori_knife_conf}', os.getcwd()+'/knife.rb')
        copyfile(os.getcwd()+f'/.chef/{client_key}', os.getcwd()+f'/{client_key}')




# enter_chef_block(ori_knife_conf, client_key)

def confirm(prompt=None, resp=False):
    """prompts for yes or no response from the user. Returns True for yes and
    False for no.

    'resp' should be set to the default value assumed by the caller when
    user simply types ENTER.

    >>> confirm(prompt='Create Directory?', resp=True)
    Create Directory? [y]|n: 
    True
    >>> confirm(prompt='Create Directory?', resp=False)
    Create Directory? [n]|y: 
    False
    >>> confirm(prompt='Create Directory?', resp=False)
    Create Directory? [n]|y: y
    True

    """

    fileslist = []
    for dirpath, dirname, filenames in os.walk(os.getcwd()):
        fileslist.append(filenames)
    
    pattern = '*.pem'
    matching = fnmatch.filter(fileslist[0], pattern)[0]
    matching_str = ''.join(matching)
    current_block = (matching_str.split('.')[0]).split('-')[1]
     
    
    if prompt is None:
        prompt = f'You currently {current_block.upper()} block, you want change chef block or not'

    if resp:
        prompt = f'{prompt}, [n]|y: '
    else:
        prompt = f'{prompt} [n]|y: '
        
    while True:
        ans = input(prompt)
        if not ans:
            return resp
        if ans not in ['y', 'Y', 'n', 'N']:
            print('please enter y or n.')
            continue
        if ans == 'y' or ans == 'Y':
            block_var = input("Input the chef block you wanna enter:") 
            ori_knife_conf = 'knife-'+block_var+'.rb'
            client_key = 'jxi-'+block_var+'.pem'
            # print(ori_knife_conf)
            # print(client_key)
            enter_chef_block(ori_knife_conf, client_key)
            return True
        if ans == 'n' or ans == 'N':
            print('Whish you have a good day! :)')
            return False


confirm()
