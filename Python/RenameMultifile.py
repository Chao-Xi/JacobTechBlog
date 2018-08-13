import os

os.chdir('/Users/jxi/python/adv1/parse_dir')

for f in os.listdir():
	# print(f)
	f_name, f_ext = os.path.splitext(f)
	f_series, f_title, f_year = f_name.split('-')
	f_series=f_series.strip()
	f_title=f_title.strip()
	f_year=f_year.strip()
	
	new_name='{}-{}{}'.format(f_year, f_title, f_ext)
	os.rename(f, new_name)

#input:  ac-blackflag-14.txt
#output: 14-blackflag.txt 	


