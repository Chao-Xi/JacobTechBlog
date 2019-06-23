import csv
import numpy as np
# import pandas as pd
from collections import Counter
from matplotlib import pyplot as plt

# import os
# cwd = os.getcwd()
# print(cwd)

plt.style.use("fivethirtyeight")

# data = pd.read_csv('data.csv')

with open('Code_in_SAP/data.csv') as csv_file:
    csv_reader = csv.DictReader(csv_file)

    language_counter = Counter() # from collections

    for row in csv_reader:
        language_counter.update(row['LanguagesWorkedWith'].split(';'))

# print(language_counter.most_common(15))

languages = []
popularity = []

for item in language_counter.most_common(15):
    languages.append(item[0])
    popularity.append(item[1])

# Reverse the list 

# languages.reverse()
# popularity.reverse()

plt.barh(languages, popularity)
# barh => horizontal bar

plt.title("Most Popular Languages")
# plt.ylabel("Programming Languages")
plt.xlabel("Number of People Who Use")

plt.tight_layout()

plt.show()