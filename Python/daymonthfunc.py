
#Number day of per month, first value placeholder for indexing purpose
month_days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
print(len(month_days))
# 13

def is_leap(year):
	"""Return true for leap year, False for no-leap years"""
	return year % 4 == 0 and (year % 100 !=0 or year % 400 ==0)	
# False


print(is_leap(2018))
	
def days_in_month(year,month):
	"""Return number of days in that month in that year"""
	if not 1 <= month <= 12:
		return 'Invalid Month'

	if month == 2 and is_leap(year):
		return 29

	return month_days[month]	

print(days_in_month(2016,2))	
# 29
