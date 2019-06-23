
from matplotlib import pyplot as plt

plt.style.use("fivethirtyeight")

slices = [20,40,15,25]
labels = ['Brand-New','99New','89New','Half-New']
colors = ['#008fd5', '#fc4f30', '#e5ae37', '#6d904f']

plt.pie(slices)
plt.pie(slices, labels=labels, colors=colors, wedgeprops={'edgecolor':'black'})

plt.title("My Awesome Pie Chart")
plt.tight_layout()
plt.show()

# Colors:
# Blue = #008fd5
# Red = #fc4f30
# Yellow = #e5ae37
# Green = #6d904f