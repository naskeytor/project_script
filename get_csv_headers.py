
import csv
import os

#file_name = "Air_Traffic_Passenger_Statistics.csv"
file_name = os.path.join(os.getcwd(), "Air_Traffic_Passenger_Statistics.csv")

with open(file_name, "r") as f:
    lector_csv = csv.reader(f)
    header_list = next(lector_csv)

text_var = 'text'
int_var = 'int'
l = []
for i in header_list:
    if i == 'Activity Period' or i == 'Passenger Count' or i == 'Adjusted Passenger Count' or i == 'Year':
        l.append('"{}" {} '.format(i, int_var))
    else:
        l.append('"{}" {} '.format(i, text_var))
l.insert(0, '"id" INT PRIMARY KEY')
res = ",".join(l)
print("CREATE TABLE my_table ({});".format(res))

