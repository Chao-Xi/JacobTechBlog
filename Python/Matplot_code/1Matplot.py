from matplotlib import pyplot as plt
print(plt.style.available)
# plt.style.use('fivethirtyeight')
# plt.style.use('ggplot')
plt.xkcd()

# https://matplotlib.org/api/_as_gen/matplotlib.pyplot.plot.html
ages_x = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]
dev_y = [17784, 16500, 18012, 20628, 25206, 30252, 34368, 38496, 42000, 46752, 49320]

# plt.plot(ages_x, dev_y, 'k--', label='All Devs')
plt.plot(ages_x, dev_y, color='#444444', linestyle='--', marker='.', label='All Devs')

py_dev_y = [20046, 17100, 20000, 24744, 30500, 37732, 41247, 45372, 48876, 53850, 57287]

plt.plot(ages_x, py_dev_y, color='b', marker='o', linewidth=3, label='Python')

js_dev_y = [16446, 16791, 18942, 21780, 25704, 29000, 34372, 37810, 43515, 46823, 49293]

plt.plot(ages_x, js_dev_y, color='red', marker='.', linewidth=2, label='Javascript')

plt.xlabel('Ages')
plt.ylabel('Median Salary (USD)')
plt.title('Median Slary (USD) by Age')

# plt.legend(['All Devs','python'])

plt.legend()

plt.tight_layout()
plt.grid(True)
# plt.savefig('./plot.png')

# plt.show()




