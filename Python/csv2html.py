import csv

html_output = ''
names = []

with open('patron.csv','r') as data_file:
	csv_data = csv.DictReader(data_file) 
	#we dont want first line as dummy line
	next(csv_data)

	for line in csv_data:
		if line['FirstName'] == "No Reward":
			break
		names.append(f"{line['FirstName']} {line['LastName']}")

# for name in names:
# 	print(name)
html_output += f'<p>There are currently {len(names)} public contributors. Thank you!</p>'
html_output += '\n<ul>'
for name in names:
	html_output += f'\n\t<li>{name}</li>'
html_output += '\n</ul>'

print(html_output)

with open ('patrons.html', 'w') as wf:
	for line in html_output:
		wf.write(line)


# <p>There are currently 30 public contributors. Thank you!</p>
# <ul>
# 	<li>John Doe</li>
# 	<li>Dave Smith</li>
# 	<li>Mary Jacobs</li>
# 	<li>Jane Stuart</li>
#     ...
# </ul>